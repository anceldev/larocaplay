//
//  AuthManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import FirebaseMessaging
import Observation
import RevenueCat
import RevenueCatUI
import Supabase
import SwiftData
import os


enum AuthError: LocalizedError, Equatable {
    case networkError
    case sessionExpired
    case conversionFailed
    case userNotFound
    case profileNotFound
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError: return "No hay conexión a internet."
        case .sessionExpired: return "Tu sesión ha expirado, por favor vuelve a iniciar sesión."
        case .conversionFailed: return "No pudimos vincular tu cuenta."
        case .userNotFound: return "No encontramos tu cuenta de usuario."
        case .profileNotFound: return "No encontramos tu perfil de usuario"
        case .unknown(let message): return message
        }
    }
    
}

enum AuthManagerError: Error, LocalizedError, Equatable {
    case modelNotFound
    case couldNotRepairProfile
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound: return "No se ha encontrado el modelo del usuario"
        case .couldNotRepairProfile: return "No se pudo reparar la información del perfil"
        }
    }
}
enum AuthNavigationState {
    case loading  // App cargando e inicializandose
    case onboarding  // WelcomeView (No hay sesión)
    case authorized  // MainTabView (Sesión real o anónima)
    case updatePassword
}

enum ServiceStatus {
    case healthy  // Todo OK
    case offline  // Usuario sin internet
    case serverMaintenance  // Supabase caído (Error 5xx o Timeout)
    case storeMaintenance  // RevenueCat caído
}

@Observable
final class AuthManager {
    private let service: AuthService
    private var modelContext: ModelContext?
    private var logger = Logger(subsystem: "com.larocaplay.larocaplay", category: "AuthManager")
    
    var session: Supabase.Session?
    var isLoading: Bool = false
    
    var error: AuthError?
    var errorMessage: String?
    var showAlertError: Bool = false
    
    var currentUserProfile: UserProfile?
    var customerInfo: CustomerInfo?
    
    var navigationState: AuthNavigationState = .onboarding
    var serviceStatus: ServiceStatus = .healthy
    
    var pendingDeepLink: URL?
    
    var isSubscriptionActive: Bool {
        guard let currentUserProfile else {
            return false
        }
        if currentUserProfile.profileRole == .admin {
            return true
        }
        guard let entitlement = customerInfo?.entitlements["pro"] else {
            return false
        }
        return entitlement.isActive
    }
    
    var isAnonymous: Bool {
        session?.user.isAnonymous ?? true
    }
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    init(service: AuthService) {
        self.service = service
    }
    
    func setContext(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext
        logger.info("Contexto de SwiftData recibido correctamente")
    }
    
    @MainActor
    func initialize() async {
        self.navigationState = .loading
        self.isLoading = true
        defer { self.isLoading = false }
        
        let currentSession: Session
        do {
            currentSession = try await service.getCurrentSession()
            self.session = currentSession
        } catch {
            logger.error("No hay sesión: \(error)")
            self.navigationState = .onboarding
            return
        }
        
        let local = loadLocalProfile(id: currentSession.user.id)
        if let local {
            self.currentUserProfile = local
        } else if self.isAnonymous {
            self.currentUserProfile = createTemporaryGuestProfile(for: currentSession.user)
        } else {
            do {
                self.currentUserProfile = try await refreshProfile()
                self.serviceStatus = .healthy
            } catch {
                logger.info("Error: \(error)")
                self.errorMessage = "No se ha podido recuperar la información de su perfil."
            }
        }
        
//        guard self.currentUserProfile != nil else {
        guard let currentUserProfile else {
            self.navigationState = .onboarding
            return
        }
        await NotificationManager.shared.fetchAndSyncSettings(userId: currentUserProfile.userId, context: modelContext)
        self.navigationState = .authorized
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    NotificationManager.shared.updateTokenInSupabase()
                }
                group.addTask {
                    do {
                        let dto = try await self.service.fetchProfile(id: self.session!.user.id)
                        await MainActor.run {
                            if let updated = try? self.syncProfileToLocal(dto: dto) {
                                self.currentUserProfile = updated
                            }
                            if self.serviceStatus != .storeMaintenance {
                                self.serviceStatus = .healthy
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.handleNetworkError(error, service: .supabase)
                        }
                    }
                }
                group.addTask {
                    do {
                        try await self.syncWithThirdParties()
                        await MainActor.run {
                            if self.serviceStatus == .storeMaintenance {
                                self.serviceStatus = .healthy
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.handleNetworkError(error, service: .revenueCat)
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            let newSession = try await withThrowingTaskGroup(of: Supabase.Session.self) { group in
                group.addTask {
                    return try await self.service.signIn(email: email, password: password)
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: 8 * 1_000_000_000) // 8 segundos
                    throw URLError(.timedOut)
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }
            
            self.session = newSession
            
            if let local = loadLocalProfile(id: newSession.user.id){
                self.currentUserProfile = local
            } else {
                let dto = try await service.fetchProfile(id: newSession.user.id)
                self.currentUserProfile = try syncProfileToLocal(dto: dto)
            }
            
            await NotificationManager.shared.fetchAndSyncSettings(userId: self.session!.user.id, context: modelContext)
            self.navigationState = .authorized

            Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        do {
                            try await self.syncWithThirdParties()
                        } catch {
                            await MainActor.run { self.serviceStatus = .storeMaintenance }
                        }
                    }
                    group.addTask {
                        do {
                            let dto = try await self.service.fetchProfile(id: newSession.user.id)
                            await MainActor.run {
                                _ = try? self.syncProfileToLocal(dto: dto)
                            }
                        } catch {
                            self.logger.warning("No se pudo refrescar el perfil tras el login")
                        }
                    }
                    group.addTask {
                        self.registerToken()
                    }
                }
            }
        } catch let error as Supabase.AuthError {
            handleSignInError(error)
            self.navigationState = .onboarding
        } catch let error as URLError {
            handleNetworkError(error, service: .supabase)
            self.navigationState = .onboarding
        } catch {
            
            print(error)
            print(error.localizedDescription)
            handleError(.unknown("Credenciales incorrectass"))
            self.navigationState = .onboarding
        }
    }
    @MainActor
    func signUp(email: String, password: String, confirmPassword: String) async {
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        
        do {
            try checkPasswordsField(password: password, confirmPassword: confirmPassword)
            if self.session != nil {
                _ = try await service.updateUser(email: email, password: password)
            } else {
                _ = try await service.signUp(email: email, password: password)
            }
            
            let newSession = try await service.getCurrentSession()
            self.session = newSession
            
            let dto = try await service.fetchProfile(id: newSession.user.id)
            self.currentUserProfile = try syncProfileToLocal(dto: dto)
            await NotificationManager.shared.fetchAndSyncSettings(userId: self.session!.user.id, context: modelContext)
            self.navigationState = .authorized
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        self.registerToken()
                    }
                    group.addTask {
                        do {
                            try await self.syncWithThirdParties()
                        } catch {
                            await MainActor.run { self.serviceStatus = .storeMaintenance }
                        }
                    }
                }
            }
        } catch let error as SignUpError {
            handleSignupError(error)
            self.navigationState = .onboarding
        } catch let error as Supabase.AuthError {
            logger.error("Error en autenticación: \(error)")
            handleSignupSupabaseAuthError(error.errorCode)
            self.navigationState = .onboarding
        } catch {
            logger.error("Error inesperado en signUp: \(error.localizedDescription)")
            handleError(.unknown("No se pudo completar el registro"))
            self.navigationState = .onboarding
        }
    }
    @MainActor
    func startGuestSession() async {
        self.navigationState = .loading
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            let guestSession = try await service.signInAnonymously()
            self.session = guestSession
            self.currentUserProfile = createTemporaryGuestProfile(for: guestSession.user)
            self.navigationState = .authorized
            Task {
                try? await self.syncWithThirdParties()
            }
            
        } catch {
            logger.error("Error al iniciar sesión anónima: \(error.localizedDescription)")
            handleError(.networkError)
            self.navigationState = .onboarding
        }
    }
    private func createTemporaryGuestProfile(for user: Supabase.User) -> UserProfile {
        UserProfile(
            userId: user.id,
            displayName: "Invitado",
            profileRole: .member
        )
        //        self.currentUserProfile = guest
    }
    @MainActor
    func refreshProfile() async throws -> UserProfile {
        guard let user = session?.user else {
            throw Supabase.AuthError.sessionMissing
        }
        
        do {
            let dto = try await service.fetchProfile(id: user.id)
            let userProfile = try syncProfileToLocal(dto: dto)
            self.error = nil
            return userProfile
        } catch let error as PostgrestError {
            if error.code == "PGRST116" {
                logger.info("No hay ningun perfil asociado en la DB")
                do {
                    let repairedProfile = try await tryToRepairProfile()
                    return repairedProfile
                } catch {
                    throw AuthManagerError.couldNotRepairProfile
                }
            }
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                logger.error("No hay conexión a internet")
            case .timedOut:
                logger.error("La solicitud expiró. Supabase podría estar lento o caído")
            default:
                logger.error("Error de red: \(error.localizedDescription)")
            }
            handleNetworkError(error, service: .supabase)
            throw error
        } catch let error as AuthManagerError {
            logger.error("No se ha podido obtener modelo de cache local: \(error.localizedDescription)")
            throw error
        } catch {
            logger.error("Error relacionado con SwiftData: \(error.localizedDescription)")
            throw error
        }
    }
    /// Carga el perfil de la cache local, si existe.
    /// - Parameters:
    ///   - id: id del perfil que se tiene que cargar.
    private func loadLocalProfile(id: UUID) -> UserProfile? {
        guard let modelContext = modelContext else {
            logger.error("ModelContext no configurado en AuthManager")
            return nil
        }
        let targetID = id
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { profile in
                profile.userId == targetID
            }
        )
        do {
            let localProfile = try modelContext.fetch(descriptor).first
            return localProfile
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    /// Vincula la cuenta del backend al cache local. Si existe lo actualiza, si no lo crea.
    /// - Parameters:
    ///   - dto: Perfil del backend.
    @MainActor
    private func syncProfileToLocal(dto: ProfileDTO) throws -> UserProfile {
        guard let context = modelContext else {
            logger.error("ModelContext no configurado en AuthManager")
            throw SwiftDataError.missingModelContext
        }
        let targetUUID = dto.id
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { profile in
                profile.userId == targetUUID
            }
        )
        do {
            let localProfile = try context.fetch(descriptor).first
            if let profile = localProfile {
                profile.displayName = dto.displayName ?? "Usuario"
                profile.email = dto.email
                profile.avatarId = dto.avatarId
            } else {
                let newProfile = dto.toModel()
                context.insert(newProfile)
            }
            try context.save()
            let userProfile = try context.fetch(descriptor).first
            
            guard let userProfile else {
                throw AuthManagerError.modelNotFound
            }
            return userProfile
        } catch {
            logger.error("Error crítico en SwiftData: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    @MainActor
    private func tryToRepairProfile() async throws -> UserProfile {
        logger.info("Iniciando reparación del perfil...")
        guard let user = self.session?.user else {
            throw Supabase.AuthError.sessionMissing
        }
        let newProfileDTO = try await service.createInitialProfile(id: user.id, email: user.email!)
        let newProfile = try syncProfileToLocal(dto: newProfileDTO)
        return newProfile
    }
    
    /// Cierra la sesión actual.
    @MainActor
    func signOut() async {
        self.isLoading = true
        defer { self.isLoading = false }
        await NotificationManager.shared.removeDeviceOnLogout()
        do {
            try await service.signout()
            _ = try await Purchases.shared.logOut()
            self.session = nil
            self.currentUserProfile = nil
            self.navigationState = .onboarding
        } catch {
            logger.error("No se pudo cerrar la sesión: \(error)")
            handleError(.unknown("No se pudo cerrar la sesión"))
        }
    }
    @MainActor
    func signOutAllSessions() async {
        guard let userId = session?.user.id else { return }
        do {
            try await service.signOutAllDevices(userId: userId)
        } catch {
            logger.error("Error en cierre global de sesiones: \(error)")
        }
    }
    
    @MainActor
    func resetPassword(for email: String) async {
        do {
            try await service.sendResetPasswordEmail(to: email)
            guard let session else { return }
            await signOutAllSessions()
            await signOut()
            NotificationManager.shared.clearLocalCache()
        } catch {
            logger.error("Error al enviar correo de recuperación: \(error)")
            print(error.localizedDescription)
            
        }
    }
    @MainActor
    func getSesssionFromUrlCode(url: URL) {
        guard url.host == "reset-password" else {
            if url.scheme == "larocaplay" {
                self.pendingDeepLink = url
            }
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        Task {
            do {
                self.session = try await service.getSessionFromCode(code: code)
                try await syncWithThirdParties()
                self.navigationState = .updatePassword
            } catch {
                logger.error("Error al obtener sesion con el code: \(error)")
                self.navigationState = .onboarding
            }
        }
    }
    @MainActor
    func updatePassword(with newPassword: String, and confirmPassword: String) async {
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        do {
            try checkPasswordsField(password: newPassword, confirmPassword: confirmPassword)
            _ = try await service.updatePassword(with: newPassword)
            guard let currentSession = self.session else { return }
            
            
            let local = loadLocalProfile(id: currentSession.user.id)
            if let local {
                self.currentUserProfile = local
            } else {
                do {
                    self.currentUserProfile = try await refreshProfile()
                    self.serviceStatus = .healthy
                } catch {
                    logger.info("Error: \(error)")
                    self.errorMessage = "No se ha podido recuperar la información de su perfil."
                }
            }
            Task {
                registerToken()
            }
            
            self.navigationState = .authorized
        } catch {
            print(error)
            print(error.localizedDescription)
            logger.error("Error al actualizar la contraseña: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteAccount() async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            // Borrado en el servidor de supabase
            try await service.deleteAccount()
            await NotificationManager.shared.removeDeviceOnLogout()
            // Cerramos sesión en RevenueCat (esperamos que termine)
            _ = try? await Purchases.shared.logOut()
            // Cerramos sesión en supabase
            try await service.signout()
            self.currentUserProfile = nil
            self.session = nil
            self.navigationState = .onboarding
        } catch {
            logger.error("Error al borrar la cuenta: \(error)")
        }
    }
    
    /// Vincula la cuenta actual con la de RevenueCat correspondiente
    private func syncWithThirdParties() async throws {
        guard let userId = session?.user.id.uuidString.lowercased() else { return }
        let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        self.customerInfo = customerInfo
    }
    @MainActor
    func refreshSubscriptionStatus() async {
        do {
            self.customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    /// Manejo de errores.
    /// - Parameters:
    ///   - error: Maneja los AuthError.
    private func handleError(_ error: AuthError) {
        self.error = error
        self.showAlertError = true
    }

    private func registerToken() {
        guard let token = Messaging.messaging().fcmToken else {
            logger.warning("No hay token")
            return
        }
        NotificationManager.shared.updateTokenInSupabase(token: token)
    }
}

extension AuthManager {
    private enum ServiceType { case supabase, revenueCat, vimeo }
    
    private func handleNetworkError(_ error: Error, service: ServiceType) {
        // 1. ¿Es un error de conexión física?
        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            self.serviceStatus = .offline
            self.errorMessage = "No hay conexión a internet"
            return
        }
        
        // 2. ¿Es un error de servidor (5xx) o Timeout?
        let isServerIssue = (error as? PostgrestError)?.code?.starts(with: "5") ?? false
        let isTimeout = (error as? URLError)?.code == .timedOut
        
        if isServerIssue || isTimeout {
            if service == .supabase {
                self.serviceStatus = .serverMaintenance
                self.errorMessage = "Error de conexión con el servidor.\nInténtalo más tarde"
            } else {
                self.serviceStatus = .storeMaintenance
                self.errorMessage = "Error de conexión con la tienda.\nNo se pueden hacer compras"
            }
        }
    }
    
    private func handleSignInError(_ error: Supabase.AuthError) {
        switch error.errorCode {
        case .invalidCredentials: self.errorMessage = "Correo electrónico o contraseña inválidos"
        case .userNotFound: self.errorMessage = "El email no existe en la base de datos"
        case .overRequestRateLimit: self.errorMessage = "Demasiados intentos fallidos. Inténtalo más tarde"
        default: self.errorMessage = "Error en sistema de autenticación"
        }
    }

    private func handleSignupError(_ error: SignUpError) {
        switch error {
        case .passwordsDoNotMatch: self.errorMessage = "Las contraseñas no coinciden"
        case .unknownError: self.errorMessage = "Error desconocido"
        }
        return
    }
    
    private func handleSignupSupabaseAuthError(_ errorCode: Supabase.ErrorCode) {
        switch errorCode {
        case .emailExists: self.errorMessage = "El correo electrónico ya está registrado"
        case .invalidCredentials: self.errorMessage = "Correo electrónico o contraseña inválidos"
        case .overRequestRateLimit:
            self.errorMessage =
            "Has intentado iniciar sesión demasiadas veces en un corto periodo de tiempo, por favor espera un tiempo para volver a intentarlo"
        case .signupDisabled: self.errorMessage = "Registrarse no está disponible en este momento"
        default: self.errorMessage = "Error en el sistema de autenticación"
        }
    }
    
    /// Comprueba que dos contraseñas sean validas. Aux function para signup
    private func checkPasswordsField(password: String, confirmPassword: String) throws {
        if password == confirmPassword { return }
        throw SignUpError.passwordsDoNotMatch
    }
}

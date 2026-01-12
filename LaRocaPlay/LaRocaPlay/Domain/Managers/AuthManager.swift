//
//  AuthManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import Observation
import RevenueCat
import RevenueCatUI
import Supabase
import SwiftData
import os

enum AuthState {
    case unauthenticated
    case authenticating
    case authenticated
}

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
    private var log = Logger(subsystem: "com.larocaplay.larocaplay", category: "AuthManager")
    
    var session: Supabase.Session?
    var isLoading: Bool = false
    
    var error: AuthError?
    var errorMessage: String?
    var showAlertError: Bool = false
    
    var currentUserProfile: UserProfile?
    var customerInfo: CustomerInfo?
    
    var navigationState: AuthNavigationState = .onboarding
    var serviceStatus: ServiceStatus = .healthy
    
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
        log.info("Contexto de SwiftData recibido correctamente")
    }
    
    @MainActor
    func initialize() async {
        self.navigationState = .loading
        self.isLoading = true
        defer { self.isLoading = false }
        
//        do {
//            let session = try await service.getCurrentSession()
//            self.session = session
//            loadLocalProfile(id: session.user.id)
//        } catch let error as Supabase.AuthError where error == .sessionMissing {
//            log.info("No hay sesión")
//            self.navigationState = .onboarding
//            return
//        } catch let error as URLError {
//            log.error("Error de red: \(error.localizedDescription)")
//            self.navigationState = .onboarding
//            self.serviceStatus = .offline
//            self.errorMessage = "Necesitas conexión a internet para empezar"
//            return
//        } catch {
//            log.error("No se pudo conectar con servidor de datos: \(error.localizedDescription)")
//            self.navigationState = .onboarding
//            self.serviceStatus = .serverMaintenance
//            self.errorMessage = "No se ha podido conectar con el servidor de datos. Inténtalo más tarde"
//            return
//        }
        do {
            let session = try await service.getCurrentSession()
            self.session = session
            loadLocalProfile(id: session.user.id)
        } catch {
            log.info("No hay sesión")
            self.navigationState = .onboarding
            return
        }
        
        do {
            try await syncWithThirdParties()
        } catch {
            log.error("Error en tienda \(error)")
            log.warning("No se pueden realizar suscripciones")
            self.serviceStatus = .storeMaintenance
        }
        
        do {
            try await refreshProfile()
        } catch let error as AuthError where error == .profileNotFound {
            // log.error("No se encontró el perfil en supabase")  // Si no hay perfil en supabase, el usuario no existe
            log.warning("No se puede realizar la autenticación")
            self.navigationState = .onboarding
            return
        } catch {
            log.error("Servidor de supabase no disponible")
            log.warning("No se puede realizar la autenticación")
            self.serviceStatus = .serverMaintenance
            self.errorMessage = "No se puede conectar con el servidor de autenticación. Inténtalo más tarde"
        }
        self.navigationState = .authorized
    }
    
    @MainActor
    func signIn(email: String, password: String) async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            self.session = try await service.signIn(email: email, password: password)
            loadLocalProfile(id: self.session!.user.id)
            try await syncWithThirdParties()
            try? await refreshProfile()
            self.navigationState = .authorized
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
        defer { isLoading = false }
        do {
            //            try Validations.shared.isValidEmail(email)
            try checkPasswordsField(password: password, confirmPassword: confirmPassword)
            
            if let session {
                _ = try await service.updateUser(email: email, password: password)
            } else {
                _ = try await service.signUp(email: email, password: password)
            }
            self.session = try await service.getCurrentSession()
            loadLocalProfile(id: self.session!.user.id)
            try await syncWithThirdParties()
            try await refreshProfile()
            self.navigationState = .authorized
        } catch let error as SignUpError {
            handleSignupError(error)
            self.navigationState = .onboarding
        } catch let error as Supabase.AuthError {
            handleSignupSupabaseAuthError(error.errorCode)
            self.navigationState = .onboarding
        } catch {
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
            try await loginAnonymously()
            self.navigationState = .authorized
        } catch {
            handleError(.networkError)
            self.navigationState = .onboarding
        }
    }
    
    /// Inicia una sesión anonima para invitados.
    @MainActor
    func loginAnonymously() async throws {
        do {
            let session = try await service.signInAnonymously()
            self.session = session
            try await syncWithThirdParties()
            try await refreshProfile()
        } catch {
            print(error)
            print(error.localizedDescription)
            throw AuthError.networkError
        }
    }
    
    /// Actualiza los datos del perfil actual.
    @MainActor
    func refreshProfile() async throws {
        guard let user = session?.user else { return }
        if self.isAnonymous && self.currentUserProfile == nil {
            log.info("Usuario anónimo, usando perfil temporal")
            self.currentUserProfile = createTemporaryGuestProfile(for: user)
            return
        }
        do {
            let dto = try await service.fetchProfile(id: user.id)
            syncProfileToLocal(dto: dto)
            self.error = nil
        } catch let error as PostgrestError {
            if error.code == "PGRST116" {
                // print("No hay ningun perfil asociado en la DB")
                log.info("No hay ningun perfil asociado en la DB")
                if currentUserProfile == nil {
                    throw AuthError.profileNotFound
                }
            }
            throw error
        } catch {
            throw error
        }
    }
    @MainActor
    func refreshSubscriptionStatus() async {
        do {
            self.customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            // print(error.localizedDescription)
            //      log.error(error.localizedDescription)
            log.error("\(error.localizedDescription)")
        }
    }
    
    /// Crea un perfil temporal para un usuario. Se usa en caso de que no haya aún un perfil asociado en el backend.
    /// - Parameters:
    ///   - user: Usuario de backend.
    private func createTemporaryGuestProfile(for user: Supabase.User) -> UserProfile {
       UserProfile(
            userId: user.id,
            displayName: "Invitado",
            profileRole: .member
        )
//        self.currentUserProfile = guest
    }
    
    /// Cierra la sesión actual.
    @MainActor
    func signOut() async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            try await service.signout()
            _ = try await Purchases.shared.logOut()
            
            self.session = nil
            self.currentUserProfile = nil
            
            self.navigationState = .onboarding
            //            await initialize()
        } catch {
            print(error)
            print(error.localizedDescription)
            handleError(.unknown("No se pudo cerrar la sesión"))
        }
    }
    
    @MainActor
    func deleteAccount() async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            // Borrado en el servidor de supabase
            try await service.deleteAccount()
            // Cerramos sesión en RevenueCat (esperamos que termine)
            _ = try? await Purchases.shared.logOut()
            // Cerramos sesión en supabase
            try await service.signout()
            self.currentUserProfile = nil
            self.session = nil
            self.navigationState = .onboarding
        } catch {
            print(error)
            
        }
    }
    
    /// Carga el perfil de la cache local, si existe.
    /// - Parameters:
    ///   - id: id del perfil que se tiene que cargar.
    private func loadLocalProfile(id: UUID) {
        guard let modelContext = modelContext else {
            // print("Error: ModelContext no configurado en AuthManager")
            log.error("ModelContext no configurado en AuthManager")
            return
        }
        //        let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile>{ $0.userId == userId })
        let targetID = id
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { profile in
                profile.userId == targetID
            }
        )
        do {
            let results = try modelContext.fetch(descriptor)
            let localModel = results.first
            self.currentUserProfile = localModel
        } catch {
            // print("DEBUG: Todavía no hay perfil local")
            log.warning("Todavía no hay perfil local")
            // print(error)
            //      log.error(error.localizedDescription)
            log.error("\(error.localizedDescription, privacy: .public)")
            
        }
    }
    
    /// Vincula la cuenta del backend al cache local. Si existe lo actualiza, si no lo crea.
    /// - Parameters:
    ///   - dto: Perfil del backend.
    private func syncProfileToLocal(dto: ProfileDTO) {
        // TODO: Guardar el perfil en SwiftData de manera local.
        guard let context = modelContext else {
            // print("Error: ModelContext no configurado en AuthManager")
            log.error("ModelContext no configurado en AuthManager")
            return
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
                // print("Perfil local actualizado correctamente")
            } else {
                let newProfile = dto.toModel()
                context.insert(newProfile)
                // print("Prefil creado correctamente")
            }
            try context.save()
            self.currentUserProfile = try context.fetch(descriptor).first
        } catch {
            print(error)
        }
    }
    
    /// Vincula la cuenta actual con la de RevenueCat correspondiente
    private func syncWithThirdParties() async throws {
        guard let userId = session?.user.id.uuidString.lowercased() else { return }
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(userId)
            self.customerInfo = customerInfo
        } catch {
            // print("Error vinculando con RevenueCat: \(error)")
            log.error("Error vinculando con RevenueCat: \(error)")
            print(type(of: error))
            throw error
        }
    }
    
    /// Manejo de errores.
    /// - Parameters:
    ///   - error: Maneja los AuthError.
    private func handleError(_ error: AuthError) {
        self.error = error
        self.showAlertError = true
    }
    
    @MainActor
    func updatePassword(with newPassword: String, and confirmPassword: String) async {
        self.isLoading = true
        self.errorMessage = nil
        defer { self.isLoading = false }
        do {
            try checkPasswordsField(password: newPassword, confirmPassword: confirmPassword)
            _ = try await service.updatePassword(with: newPassword)
            guard self.session != nil else { return }
            self.navigationState = .authorized
        } catch {
            print(error)
            print(error.localizedDescription)
            log.error("Error al actualizar la contraseña: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func resetPassword(for email: String) async {
        do {
            try await service.sendResetPasswordEmail(to: email)
        } catch {
            // print("ERROR: Error enviando correo de recuperación")
            log.error("Error al enviar correo de recuperación: \(error)")
            print(error.localizedDescription)
            
        }
    }
    
    func getSessionFromUrl(from url: URL) async {
        
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            self.session = try await service.getSessionFromUrl(from: url)
            self.navigationState = .updatePassword
            
        } catch {
            // print("ERROR: Error al procesar el link")
            log.error("Error al procesar el link: \(error)")
            // print(error)
            // print(error.localizedDescription)
            self.navigationState = .onboarding
        }
    }
}

extension AuthManager {
    private enum ServiceType { case supabase, revenueCat }
    private func handleNetworkError(_ error: Error, service: ServiceType) {
        // 1. ¿Es un error de conexión física?
        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            self.serviceStatus = .offline
            return
        }
        
        // 2. ¿Es un error de servidor (5xx) o Timeout?
        let isServerIssue = (error as? PostgrestError)?.code?.starts(with: "5") ?? false
        let isTimeout = (error as? URLError)?.code == .timedOut
        
        if isServerIssue || isTimeout {
            if service == .supabase {
                self.serviceStatus = .serverMaintenance
            } else {
                self.serviceStatus = .storeMaintenance
            }
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

//
//  AuthManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import Observation
import Supabase
import SwiftData
import RevenueCat
import RevenueCatUI

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
    case loading        // App cargando e inicializandose
    case onboarding     // WelcomeView (No hay sesión)
    case authorized     // MainTabView (Sesión real o anónima)
}

@Observable
final class AuthManager {
    private let supabaseClient = SBCLient.shared.supabase
    private let service: AuthService
    
    //    var authState: AuthState = .unauthenticated
    var session: Supabase.Session?
    var isLoading: Bool = false
    
    var error: AuthError?
    var errorMessage: String?
    var showAlertError: Bool = false
    
    //    var currentUserProfile: ProfileDTO?
    var currentUserProfile: UserProfile?
    var navigationState: AuthNavigationState = .loading
    

    private var isInitialized = false
    private var modelContext: ModelContext?
    
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
        print("DEBUG: Contexto de SwiftData recibido correctamente")
    }
    
    @MainActor
    func initialize() async {
        
        self.navigationState = .loading
        
//        guard !isInitialized else { return }
        
        self.isLoading = true
        
        defer { self.isLoading = false }
        
        self.error = nil
        
        do {
            let currentSession = try await service.getCurrentSession()
            self.session = currentSession
            
            loadLocalProfile(id: currentSession.user.id)
            try await syncWithThirdParties()
            try await refreshProfile()
            self.navigationState = .authorized
        } catch {
            print("DEBUG: Fallo al recuperar la sesión inicial: \(error.localizedDescription)")
            print(error)
            print(error.localizedDescription)
            
            if let authError = error as? AuthError, authError == .profileNotFound {
                self.error = authError
                self.showAlertError = true
                self.navigationState = .onboarding
            }
            self.navigationState = .onboarding
        }
    }
    
    /// Añade dos números enteros y devuelve la suma.
    /// - Parameters:
    ///   - a: El primer número.
    ///   - b: El segundo número.
    /// - Returns: La suma de `a` y `b`.
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
    @MainActor
    func signIn(email: String, password: String) async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            try Validations.shared.isValidEmail(email)
            try Validations.shared.isValidPassword(password)
            //            let response = try await supabaseClient.auth.signIn(email: email, password: password)
            self.session = try await service.signIn2(email: email, password: password)
            loadLocalProfile(id: self.session!.user.id)
            try await syncWithThirdParties()
            try? await refreshProfile()
            self.navigationState = .authorized
        } catch {
            print(error)
            handleError(.unknown("Credenciales incorrectass"))
            self.navigationState = .onboarding
        }
    }
    @MainActor
    func signUp(email: String,  password: String, confirmPassword: String) async {
        self.isLoading = true
        defer { isLoading = false }
        do {
            try Validations.shared.isValidEmail(email)
            try checkPasswordsField(password: password, confirmPassword: confirmPassword)
            
            _ = try await service.signUp2(email: email, password: password)
            self.session = try await service.getCurrentSession()
            loadLocalProfile(id: self.session!.user.id)
            try await syncWithThirdParties()
            try await refreshProfile()
            self.navigationState = .authorized
        } catch {
            handleError(.unknown("No se pudo completar el registro"))
            self.navigationState = .onboarding
        }
    }
    
    /// Comprueba que dos contraseñas sean validas. Aux function para signup
    private func checkPasswordsField(password: String, confirmPassword: String) throws {
        if password == confirmPassword {
            try Validations.shared.isValidPassword(password)
            return
        }
        throw SignUpError.passwordsDoNotMatch
    }
    
    /// Actualiza los datos del perfil actual.
    @MainActor
    func refreshProfile() async throws {
        guard let user = session?.user else { return }
        if self.isAnonymous && self.currentUserProfile == nil {
            print("DEBUG: Usuario anónimo, usando perfil temporal")
            createTemporaryGuestProfile(for: user)
            return
        }
        do {
            let dto = try await service.fetchProfile(id: user.id)
            syncProfileToLocal(dto: dto)
            self.error = nil
        } catch {
            if currentUserProfile == nil {
                throw AuthError.profileNotFound
            }
            print("Aviso: El perfil no está disponible en la DB")
            throw error
        }
    }
    
    /// Crea un perfil temporal para un usuario. Se usa en caso de que no haya aún un perfil asociado en el backend.
    /// - Parameters:
    ///   - user: Usuario de backend.
    private func createTemporaryGuestProfile(for user: Supabase.User) {
        let guest = UserProfile(
            userId: user.id,
            displayName: "Invitado",
            profileRole: .member
        )
        self.currentUserProfile = guest
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
            self.isInitialized = false
            self.navigationState = .onboarding
//            await initialize()
        } catch {
            handleError(.unknown("No se pudo cerrar la sesión"))
        }
    }
    
    
    
    /// Carga el perfil de la cache local, si existe.
    /// - Parameters:
    ///   - id: id del perfil que se tiene que cargar.
    private func loadLocalProfile(id: UUID) {
        guard let modelContext = modelContext else {
            print("Error: ModelContext no configurado en AuthManager")
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
//            let localModel: UserProfile? = try modelContext?.fetch(descriptor).first
            self.currentUserProfile = localModel
        } catch {
            print("DEBUG: Todavía no hay perfil local")
            print(error)
            print(error.localizedDescription)
        }
    }
    
    /// Vincula la cuenta del backend al cache local. Si existe lo actualiza, si no lo crea.
    /// - Parameters:
    ///   - dto: Perfil del backend.
    private func syncProfileToLocal(dto: ProfileDTO) {
        // TODO: Guardar el perfil en SwiftData de manera local.
        guard let context = modelContext else {
            print("Error: ModelContext no configurado en AuthManager")
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
                print("Perfil local actualizado correctamente")
            } else {
                let newProfile = dto.toModel()
                context.insert(newProfile)
                print("Prefil creado correctamente")
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
            let (customerInfo, created) = try await Purchases.shared.logIn(userId)
        } catch {
            print("Error vinculando con RevenueCat: \(error)")
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
}

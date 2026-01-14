//
//  AuthService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/8/25.
//

import Foundation
import Observation
import Supabase
import RevenueCat



@Observable
final class AuthService {
    let supabaseClient = SupabaseClientInstance.shared.publicClient
    
    var user: ProfileDTO?
    var customerInfo: CustomerInfo?
    //    var authState: AuthState = .unauthenticated
    var authState: AuthState = .authenticating
    var isPremium = false
    var currentProduct: RevenueCat.StoreProduct?
    var errorMessage: String? = nil
    init(){
        Task {
            await getSession()
        }
    }
    
    func getCurrentSession() async throws -> Session {
        return try await supabaseClient.auth.session
    }
    func fetchProfile(id: UUID) async throws -> ProfileDTO {
        try await supabaseClient
            .from("profiles")
            .select("user_id, display_name, email, avatar_id, locale, profile_role, subscription(*)")
            .eq("user_id", value: id)
            .single()
            .execute()
            .value
    }
    func signInAnonymously() async throws -> Session {
        try await supabaseClient.auth.signInAnonymously()
    }
    
    
    func getSession() async {
        do {
            let session = try await supabaseClient.auth.session
            //            self.user = try await getUSer(id: session.user.id)
            self.user = try await getProfile(for: session.user.id)
            guard let userId = self.user?.id else {
                try await signout()
                throw AuthError.userNotFound
            }
            try await getSuscriptionStatus(userId: userId.uuidString.lowercased())
            self.authState = .authenticated
        } catch {
            print(error)
            print(error.localizedDescription)
            self.authState = .unauthenticated
            self.errorMessage = "Error intentando obtener la sesión"
        }
    }
    
    func sendResetPasswordEmail(to email: String) async throws {
        try await supabaseClient.auth.resetPasswordForEmail(
            email,
            redirectTo: URL(string: Constants.appAuthRedirectTo)
        )
    }
    func updatePassword(with newPassword: String) async throws {
        try await supabaseClient.auth.update(user: UserAttributes(password: newPassword))
    }
    
    func getSessionFromUrl(from url: URL) async throws -> Session {
        try await supabaseClient.auth.session(from: url)
    }
    
    func getSuscriptionStatus(userId: String) async throws {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(userId)
            self.customerInfo = customerInfo
            guard let entitlement = customerInfo.entitlements["pro"] else {
                return
            }
            self.isPremium = entitlement.isActive
            self.currentProduct = await Purchases.shared.products([entitlement.productIdentifier]).first
        } catch {
            print(error)
            throw error
        }
    }
    func signIn(email: String, password: String) async throws -> Session {
        try await supabaseClient.auth.signIn(email: email, password: password)
    }
    
    func updateUser(email: String, password: String) async throws -> Supabase.User {
        let attributes = UserAttributes(email: email, password: password)
        return try await supabaseClient.auth.update(user: attributes)
    }
    
    func signUp(email: String, password: String) async throws {
        try await supabaseClient.auth.signUp(
            email: email,
            password: password
        )
    }
    
    func getProfile(for userId: UUID) async throws -> ProfileDTO {
        try await supabaseClient
            .from("profiles")
            .select("user_id, display_name, email, avatar_id, locale, profile_role, subscription(*)")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
    }
    func createInitialProfile(id: UUID, email: String) async throws -> ProfileDTO {
        try await supabaseClient
            .from("profiles")
            .upsert(["user_id": id.uuidString, "email": email], onConflict: "user_id")
            .select("*")
            .execute()
            .value
    }
    
    private func resetValues() {
        self.user = nil
        self.authState = .unauthenticated
        self.customerInfo = nil
        self.isPremium = false
        self.currentProduct = nil
    }
    
    func resetPassword(_ email: String) async throws {
        try await supabaseClient.auth.resetPasswordForEmail(
            email,
            redirectTo: URL(string: Constants.authRedirectUrl)
        )
    }
    
    func supabaseAutherror(error: Supabase.AuthError) -> String {
        switch error.errorCode {
        case .invalidCredentials:
            return "Correo electrónico o contraseña inválidos"
        case .userAlreadyExists, .emailExists:
            return "Ya existe una cuenta con esa dirección de correo"
        default:
            return "Error en el servicio de autenticación"
        }
    }
    
    func signout() async throws {
        do {
            try await supabaseClient.auth.signOut()
            //            self.customerInfo = try await Purchases.shared.logOut()
            //            resetValues()
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    func deleteAccount() async throws {
        // Llamamos a edge funcition que eliminará la cuenta asociada a este id.
        // TODO: Llamada a rpc para borrar la cuenta del usuario.
        try await supabaseClient
            .rpc("delete_user_account")
            .execute()
    }
}

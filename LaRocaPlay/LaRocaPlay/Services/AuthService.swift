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

enum AuthState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthError: LocalizedError {
    case noUserFound
    case noCustomerInfo
    var errorDescription: String? {
        switch self {
        case .noUserFound:
            "No hay datos del usuario"
        case .noCustomerInfo:
            "No hay datos como cliente"
        }

    }
}

@Observable
final class AuthService {
    let client = SBCLient.shared.supabase
//    var user: User?
    var user: Profile?
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
    
    func getSession() async {
        do {
            let session = try await client.auth.session
//            self.user = try await getUSer(id: session.user.id)
            self.user = try await getProfile(for: session.user.id)
            guard let userId = self.user?.id else {
                try await signout()
                throw AuthError.noUserFound
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
    
    func signIn(email: String, password: String) async throws {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.user = try await getProfile(for: session.user.id)
            guard let userId = self.user?.id else {
                try await signout()
                throw AuthError.noUserFound
            }
            try await getSuscriptionStatus(userId: userId.uuidString)
            self.authState = .authenticated
            
        } catch {
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )
            self.user = try await getProfile(for: session.user.id)
            guard let userId = self.user?.id else {
                try await signout()
                throw AuthError.noUserFound
            }
            try await getSuscriptionStatus(userId: userId.uuidString)
            self.authState = .authenticated
        } catch {
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    
    func getProfile(for userId: UUID) async throws -> Profile {
//        let profile: Profile = try await client
//            .from("profiles")
//            .select("user_id, display_name, email, avatar_id, locale, profile_role, subscription(*)")
//            .eq("user_id", value: userId)
//            .single()
//            .execute()
//            .value
        let profile = try await client
            .from("profiles")
            .select("user_id, display_name, email, avatar_id, locale, profile_role, subscription(*)")
            .eq("user_id", value: userId)
            .single()
            .execute()
        
        print(try JSONSerialization.jsonObject(with: profile.data))
        let porf = try JSONDecoder.supabaseDateDecoder.decode(Profile.self, from: profile.data)
        return porf
//        return profile
    }
    
    private func resetValues() {
        self.user = nil
        self.authState = .unauthenticated
        self.customerInfo = nil
        self.isPremium = false
        self.currentProduct = nil
    }
    
    func resetPassword(_ email: String) async throws {
        try await client.auth.resetPasswordForEmail(
            email,
            redirectTo: URL(string: "http://localhost:3000/auth/update-password")
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
            try await client.auth.signOut()
            self.customerInfo = try await Purchases.shared.logOut()
            resetValues()
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

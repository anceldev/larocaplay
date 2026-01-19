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
    
    func getCurrentSession() async throws -> Session {
        return try await supabaseClient.auth.session
    }
    func fetchProfile(id: UUID) async throws -> ProfileDTO {
        try await supabaseClient
            .from("profile")
            .select("user_id, display_name, email, avatar_id, locale, profile_role")
            .eq("user_id", value: id)
            .single()
            .execute()
            .value
    }
    func signInAnonymously() async throws -> Session {
        try await supabaseClient.auth.signInAnonymously()
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
    
    func getSessionFromCode(code: String) async throws -> Session {
        try await supabaseClient.auth.exchangeCodeForSession(authCode: code)
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
            .from("profile")
            .select("user_id, display_name, email, avatar_id, locale, profile_role, subscription(*)")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
    }
    func createInitialProfile(id: UUID, email: String) async throws -> ProfileDTO {
        try await supabaseClient
            .from("profile")
            .upsert(["user_id": id.uuidString, "email": email], onConflict: "user_id")
            .select("*")
            .execute()
            .value
    }
    
    func resetPassword(_ email: String) async throws {
        try await supabaseClient.auth.resetPasswordForEmail(
            email,
            redirectTo: URL(string: Constants.appAuthRedirectTo)
        )
    }
    
    func signout() async throws {
        try await supabaseClient.auth.signOut()
    }
    func signOutAllDevices(userId: UUID) async throws {
        try await supabaseClient
            .rpc(
                "logout_all_devices",
                params: ["targe_user_id": userId]
            )
            .execute()
    }
    func deleteAccount() async throws {
        try await supabaseClient.functions.invoke("delete-user")
    }
}

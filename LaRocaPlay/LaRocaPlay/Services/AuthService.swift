//
//  AuthService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/8/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class AuthService {
    let client = SBCLient.shared.supabase
    var user: User?
    
    init(){
        Task {
            try await getSession()
        }
    }
    
    func getSession() async throws -> User? {
        do {
            let session = try await client.auth.session
            self.user = try await getUSer(id: session.user.id)
            return self.user
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> User? {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.user = try await getUSer(id: session.user.id)
            return self.user
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws -> User? {
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )
            self.user = try await getUSer(id: session.user.id)
            return self.user
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func getUSer(id: UUID) async throws -> User {
        let user: User = try await client
            .from("users")
            .select("id, name, email, role")
            .eq("id", value: id)
            .single()
            .execute()
            .value
        
        return user
        
//        print(user)
//        let user = try await client
//            .from("users")
//            .select()
//            .eq("id", value: id)
//            .single()
//            .execute()
//        
//        print(try JSONSerialization.jsonObject(with: user.data))
////        return user
//        return .init(id: UUID(), name: "Ancel", email: "ancel@mail.com", role: .member)
    }
    func signout() async throws {
        do {
            try await client.auth.signOut()
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    
}

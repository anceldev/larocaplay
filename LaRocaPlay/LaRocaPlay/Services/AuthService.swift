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

@Observable
final class AuthService {
    let client = SBCLient.shared.supabase
    var user: User?
    var customerInfo: CustomerInfo?
    var authState: AuthState = .unauthenticated
    var isPremium = false
    var currentProduct: RevenueCat.StoreProduct?
    
    init(){
        Task {
            try await getSession()
        }
    }
    
    func getSession() async throws {
        do {
            let session = try await client.auth.session
            self.user = try await getUSer(id: session.user.id)
//            let a = try await Purchases.shared.logIn(self.user!.id.uuidString)
            try await getSuscriptionStatus()
            self.authState = .authenticated
            
            print(customerInfo)
        } catch {
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    func getSuscriptionStatus() async throws {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(self.user!.id.uuidString)
            self.customerInfo = customerInfo
            guard let entitlement = customerInfo.entitlements["pro"] else {
                return
            }
            self.isPremium = entitlement.isActive
            self.currentProduct = await Purchases.shared.products([entitlement.productIdentifier]).first
//            self.currentProduct = try await getProductInfo(productId: entitlement.productIdentifier)
//            let productIdentifier = entitlement.productIdentifier
            //            self.isPremium = customerInfo.entitlements["pro"]?.isActive ?? false
            print(self.customerInfo)
            print(self.currentProduct)
            print(self.currentProduct?.subscriptionPeriod?.unit.rawValue)
        } catch {
            print(error)
            throw error
        }
    }
    
//    private func getProductInfo(productId: String) async throws -> StoreProduct? {
//        let product = await Purchases.shared.products([productId])
//        return product.first
////        if isPremium {
////            if let entitlements = customerInfo?.entitlements["pro"] {
////                let productIdentifier = entitlements.productIdentifier
////                self.currentProduct = await Purchases.shared.products([productIdentifier]).first
////                print(self.currentProduct)
////            }
////        }
//    }
    
//    func signIn(email: String, password: String) async throws -> User? {
    
    func signIn(email: String, password: String) async throws {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.user = try await getUSer(id: session.user.id)
            try await getSuscriptionStatus()
            self.authState = .authenticated
//            return self.user
            
        } catch {
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    
//    func signUp(email: String, password: String) async throws -> User? {
    func signUp(email: String, password: String) async throws {
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password
            )
            self.user = try await getUSer(id: session.user.id)
            try await getSuscriptionStatus()
            self.authState = .authenticated
        } catch {
            print(error)
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
    }
    
    private func resetValues() {
        self.user = nil
        self.authState = .unauthenticated
        self.customerInfo = nil
        self.isPremium = false
        self.currentProduct = nil
    }
    
    func signout() async throws {
        do {
            try await client.auth.signOut()
            self.customerInfo = try await Purchases.shared.logOut()
            resetValues()
//            self.user = nil
//            self.authState = .unauthenticated
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

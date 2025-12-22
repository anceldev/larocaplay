//
//  AccountView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct AccountView: View {
    @Environment(AuthService.self) var auth
    @Environment(CollectionRepository.self) var collectionsRepository
    @Binding var account: User?
    @Binding var authState: AuthState
    @State private var errorMessage: String? = nil
    @State private var showSubscriptionSheet = false
    
    var subscriptionStatus: Bool {
        auth.customerInfo?.entitlements["pro"]?.isActive ?? false
    }

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    // TODO: Vista de perfil, con nombre de usuario y email. Editar perfil, Cambiar contraseña y cerrar sesión.
                    // TODO: Nivel de suscripción y poder modificarlo
                    if let account = auth.user {
                        VStack(spacing: 8) {
                            HStack(spacing: 0) {
                                Text("Bienvenido")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .font(.system(size: 12))
                            AccountCard(user: account)
                        }

                        VStack(spacing: 10) {
                            Text("Sesión")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                            VStack(spacing: 16) {
                                
                                Button {
                                    signout()
                                } label: {
                                    HStack {
                                        Image(.arrowDoorOut3)
                                            .foregroundStyle(.customRed)
                                        Text("Cerrar sesión")
                                            .foregroundStyle(.customRed).opacity(0.65)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(.black.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    Spacer()
                }
                .padding()
                .foregroundStyle(.dirtyWhite)
                .enableInjection()
                .sheet(isPresented: $showSubscriptionSheet) {
                    PaywallView()
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func signout() {
        Task {
            do {
                try await auth.signout()
                account = nil
                authState = .unauthenticated
                self.collectionsRepository.series.removeAll()
                let customerInfo = try await Purchases.shared.logOut()
//                try await auth.getCustomerInfor()
//                try await auth.getSuscriptionStatus()
//                print(customerInfo)
            } catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AccountView(account: .constant(PreviewData.user), authState: .constant(.authenticated))
        .environment(AuthService())
        .background(.customBlack)
}

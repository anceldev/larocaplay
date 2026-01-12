//
//  SettingsView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 11/9/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct SettingsView: View {
//    @Environment(AuthService.self) var auth
//    @Binding var account: User?
    @Environment(AuthManager.self) var authManager
    @Binding var account: ProfileDTO?
    @State var flow: AuthState
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false
    
//    var subscriptionStatus: Bool {
//        auth.customerInfo?.entitlements["pro"]?.isActive ?? false
//    }
    
    init(account: Binding<ProfileDTO?>) {
        self._account = account
        self.flow = account.wrappedValue == nil ? .unauthenticated : .authenticated
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    // TODO: Vista de perfil, con nombre de usuario y email. Editar perfil, Cambiar contraseña y cerrar sesión.
                    // TODO: Nivel de suscripción y poder modificarlo
                    if let account = authManager.currentUserProfile {
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text("Bienvenido")
                                    .fontWeight(.light)
                                Text(", \(account.email ?? "NO-MAIL")")
                                    .fontWeight(.medium)
                            }
                            .font(.system(size: 12))
                            Button {
//                                showSubscriptionSheet.toggle()
                                showPaywall.toggle()
                            } label: {
                                Text("Subscripción")
                            }
                            Button {
                                //                        print(CustomerInfo)
                            } label: {
                                Text("Show customer info")
                            }
                        }
//                        AccountCard(user: account)
                        
                        VStack(spacing: 10) {
                            Text("Cuenta")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 6)
                            VStack(spacing: 16) {
                                HStack {
                                    Image(.user)
                                    Text("Información personal")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Image(.star)
                                    Text("Suscripción")
                                    Spacer(minLength: 0)
                                    Button {
//                                        if !subscriptionStatus {
//                                            showPaywall = true
//                                        }
                                    } label: {
//                                        Text(subscriptionStatus ? "Activa" : "Sin suscripción")
//                                            .font(.system(size: 14))
//                                            .foregroundStyle(subscriptionStatus ? .customRed : .white.opacity(0.4))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Image(.bell)
                                    Text("Notificaciones")
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(.black.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        VStack(spacing: 10) {
                            Text("Preferencias")
                                .padding(.leading, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                            VStack(spacing: 16) {
                                HStack {
                                    Image(.fileContent)
                                    Text("Sobre nosotros")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(.black.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        VStack(spacing: 10) {
                            Text("Sesión")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 6)
                            VStack(spacing: 16) {
                                
                                Button {
                                    signout()
                                } label: {
                                    HStack {
                                        Image(.arrowDoorOut3)
                                            .foregroundStyle(.customRed)
                                        Text("Cerrar sesión")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(.black.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.customRed)
                    }
                    Spacer()
                }
                .padding()
                .foregroundStyle(.dirtyWhite)
                .enableInjection()
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
                .onChange(of: showPaywall) { oldValue, newValue in
                    if newValue == false {
                        getCustomerInfor()
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func getCustomerInfor() {
//        Task {
//            do {
//                guard let userId = auth.user?.id else {
//                    return
//                }
////                try await auth.getCustomerInfor()
//                try await auth.getSuscriptionStatus(userId: userId.uuidString)
//            } catch {
//                print(error.localizedDescription)
//                errorMessage = error.localizedDescription
//            }
//        }
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func signout() {
//        Task {
//            do {
//                try await auth.signout()
//                account = nil
//                flow = .unauthenticated
//                let customerInfo = try await Purchases.shared.logOut()
//                print(customerInfo)
//            } catch {
//                print(error.localizedDescription)
//                errorMessage = error.localizedDescription
//            }
//        }
    }
}

//#Preview {
//    SettingsView(account: .constant(PreviewData.user))
//        .environment(AuthService())
//        .background(.customBlack)
//}

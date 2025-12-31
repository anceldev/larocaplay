//
//  AccountScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/12/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct AccountScreen: View {
    @Environment(AppRouter.self) var router
    
    @Environment(AuthManager.self) var authManager
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false
    
    @State private var showAuthSheet = false
    
    @State private var showCustomerCenter = false

    var body: some View {
        VStack {
            TopBarScreen(title: "Cuenta", true)
            if authManager.isAnonymous {
                AnonymousView(showAuthSheet: $showAuthSheet)
            } else {
                ScrollView(.vertical) {
                    VStack {
                        VStack(spacing: 24) {
                            if let user = authManager.currentUserProfile {
                                AccountCard(user: user)
                            }
                            VStack(spacing: 10) {
                                Text("Cuenta")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .padding(.leading, 6)
                                VStack(spacing: 16) {
                                    Button {
                                        router.navigateTo(.userDetails(authManager.currentUserProfile!))
                                    } label : {
                                        HStack {
                                            Image(.user)
                                            Text("Información de perfil")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Image(.star)
                                        Text("Suscripción")
                                        Spacer(minLength: 0)
                                        Button {
                                            showPaywall = true
//                                            if !auth.isPremium {
//                                                showPaywall = true
//                                            } else {
//                                                router.navigateTo(.subscription)
//                                            }
                                        } label: {
                                            Text("Suscribe")
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    HStack {
                                        Image(.star)
                                        Text("Customer center")
                                        Spacer(minLength: 0)
                                        Button {
                                            showCustomerCenter = true
                                        } label: {
                                            Text("show")
                                        }
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
                                    Link(destination: URL(string:"https://www.google.com")!) {
                                        HStack {
                                            Image(.fileContent)
                                            Text("Sobre nosotros")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding()
                                .background(.black.opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            VStack(spacing: 10) {
                                Text("Soporte")
                                    .padding(.leading, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                VStack(spacing: 16) {
                                    //                                Link(destination: URL(string: "mailto:soporte@larocacylplay.com")!) {
                                    Button {
                                        abrirMail()
                                    } label: {
                                        
                                        HStack {
                                            Image(.lifeRing)
                                                .foregroundStyle(.orange)
                                            Text("Contacta con nosotros")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        //                                }
                                    }
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
                                        withAnimation(.easeOut) {
                                            signout()
                                        }
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
                    
                    .foregroundStyle(.dirtyWhite)
                    
                    .sheet(isPresented: $showPaywall) {
                        PaywallView()
                    }
                    .presentCustomerCenter(isPresented: $showCustomerCenter, onDismiss: {
                        print("Dismissed view")
                    })
                    .onChange(of: showPaywall) { oldValue, newValue in
                        if newValue == false {
                            getCustomerInfo()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $showAuthSheet, content: {
            AuthenticationView()
        })
        .padding()
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func signout() {
        Task {
            await authManager.signOut()
        }
    }
    private func getCustomerInfo() {
//        Task {
//            do {
//                guard let userId = auth.user?.id else {
//                    return
//                }
//                try await auth.getSuscriptionStatus(userId: userId.uuidString)
////                collections.series.removeAll()
//            } catch {
//                print(error.localizedDescription)
//                errorMessage = error.localizedDescription
//            }
//        }
    }
    private func abrirMail() {
        let email = "soporte@tudominio.com"
        let subject = "Ayuda"
        let body = "Hola, necesito ayuda con la app."
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

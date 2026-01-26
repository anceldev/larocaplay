//
//  AccountScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/12/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import SwiftData

struct AccountScreen: View {
    @Environment(AppRouter.self) private var router
    
    @Environment(AuthManager.self) private var authManager
    @Environment(LibraryManager.self) private var libManager
    @Environment(\.modelContext) private var context
    
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false
    
    @State private var showAuthSheet = false
    
    @State private var showCustomerCenter = false
    @State private var showDeleteAccountDialog = false
    
    var appVersion: String {
        guard let version = Bundle.main.releaseVersionNumber else {
            guard let version2 = Bundle.main.buildVersionNumber else {
                return "Test Versión"
            }
            return "Versión \(version2)"
        }
        return "Versión \(version)"
    }

    var body: some View {
        VStack {
            TopBarScreen(title: "Mi Cuenta", true)
            if authManager.isAnonymous {
                AnonymousView(showAuthSheet: $showAuthSheet)
            } else {
                ScrollView(.vertical) {
                    VStack {
                        VStack(spacing: 24) {
                            
                            if let user = authManager.currentUserProfile {
                                AccountCard(user: user, showPaywall: $showPaywall)
                            }
                            VStack(spacing: 10) {
                                Text("Membresía")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .padding(.leading, 6)
                                VStack(spacing: 16) {
                                    Button {
                                        if authManager.isSubscriptionActive {
                                            showCustomerCenter = true
                                        } else {
                                            showPaywall = true
                                        }
                                    } label: {
                                        HStack {
                                            Image(.sparkle3)
                                            Text(authManager.isSubscriptionActive ? "Gestionar Plan" : "Ver planes Premium")
                                            Spacer()
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .padding(.leading, 6)
                                VStack(spacing: 16) {
                                    Button {
                                        router.navigateTo(.notificationSettings)
                                    } label: {
                                        HStack {
                                            Image(.bell)
                                            Text("Notificaciones")
                                            Spacer()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                    Button {
                                        openMail()
                                    } label: {
                                        HStack {
                                            Image(.lifeRing)
                                            Text("Contactar con soporte")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding()
                                .background(.black.opacity(0.45))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }

                            VStack(spacing: 10) {
                                Text("Información")
                                    .padding(.leading, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                VStack(spacing: 16) {
                                    Button {
                                        router.navigateTo(.aboutUs)
                                    } label: {
                                        HStack {
                                            Image(.fileContent)
                                            Text("Sobre nosotros")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Link(destination: URL(string: "https://elite-acrylic-f12.notion.site/Pol-tica-de-Privacidad-de-LaRocaPlay-2e880028ca1a80f29ad2e293bcd7b704?source=copy_link")!) {
                                        HStack {
                                            Image(.lock)
                                            Text("Política de privacidad")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Image(.windowPointer)
                                        Text(appVersion)
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
                            .onPurchaseCompleted { customerInfo in
                                authManager.customerInfo = customerInfo
                            }
                        
                    }
                    .presentCustomerCenter(isPresented: $showCustomerCenter, onDismiss: {
                        print("Dismissed view")
                    })
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
//            let descriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.isPublic == false })
//            let privateCollections = try? context.fetch(descriptor)
//            await authManager.signOut(privateCollections)
            await authManager.signOut()
        }
    }

    private func deleteAccount() async {
        await authManager.deleteAccount()
    }
    private func openMail() {
        let email = "soporte@larocaplay.com"
        let subject = "Ayuda"
        let body = "Hola, mi correo es \(authManager.currentUserProfile?.email ?? "") y mi id de usuario \(authManager.currentUserProfile?.userId.uuidString, default: "").\nNecesito ayuda con la app."
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

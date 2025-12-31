//
//  OnboardingScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/11/25.
//

import SwiftUI

struct OnboardingScreen: View {
//    @Environment(AppRouter.self) var router
//    @Binding var appState: AppState
//    
//    init(_ appState: Binding<AppState>) {
//        self._appState = appState
//    }
    @Environment(AuthManager.self) var authManager
    @Binding var hideOnboarding: Bool
    
    var body: some View {
        // TODO: En esta pantalla se muestran las principales características de la app.
        NavigationStack {
            VStack {
                Spacer()
                Text("Bienvenido")
                // TODO: Carrusel de capturas de cosas llamativas de la app, cosas que el usuario puede ver
                Text("Puedes entrar ya con tu cuenta, crear una o simplemente echar un vistazo (Invitado)")
                Spacer()
                NavigationLink {
                    AuthenticationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("Iniciar sesión")
                }
                .buttonStyle(.capsuleButton(.customRed, textColor: .white))
                Button {
                    signinAsGuest()
                } label: {
                    Text("Empezar como invitado")
                }
                .buttonStyle(.capsuleButton(.white, textColor: .customBlack))
            }
            .padding(18)
            .background(.customBlack)
        }
    }
    private func signinAsGuest() {
        Task {
            await authManager.startGuestSession()
        }
    }
}

#Preview {
    OnboardingScreen(hideOnboarding: .constant(false))
}

//
//  AccountView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthService.self) var auth
    @Binding var account: User?
    @Binding var flow: AuthFlow
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            // TODO: Vista de perfil, con nombre de usuario y email. Editar perfil, Cambiar contraseña y cerrar sesión.
            // TODO: Nivel de suscripción y poder modificarlo
            if let account {
                Text("Usuario autenticado")
                Text("Usuario: \(account.email)")
                    .fontWeight(.medium)
                VStack {
                    HStack(spacing: 0) {
                        Text("Bienvenido")
                            .fontWeight(.light)
                        Text(", \(account.email)")
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 12))
                }
            }
            Spacer()
            Button {
                signout()
            } label: {
                Text("Cerrar sesión")
            }
            .buttonStyle(.borderedProminent)
            .tint(.customRed)
        }
        .padding()
        .foregroundStyle(.dirtyWhite)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func signout() {
        Task {
            do {
                try await auth.signout()
                account = nil
                flow = .unauthenticated
            } catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AccountView(account: .constant(PreviewData.user), flow: .constant(.authenticated))
        .environment(AuthService())
}

//
//  AuthenticationView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import SwiftUI

enum AuthMode {
    case login
    case signup
}

struct AuthenticationView: View {
    
    @Environment(AuthService.self) var auth
    
    @Binding var account: User?
    @Binding var flow: AuthFlow
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var authMode: AuthMode = .login
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Text("Todavía no has inicado sesión")
                .foregroundStyle(.dirtyWhite)
            
            Group {
                switch authMode {
                case .login:
                    SignInForm(
                        email: $email,
                        password: $password,
                        isLoading: $isLoading,
                        action: authAction
                    )
                case .signup:
                    SignUpForm(
                        email: $email,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        isLoading: $isLoading,
                        action: authAction
                    )
                }
            }
            VStack(spacing: 24) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.orange)
                        .font(.system(size: 13))
                }
                
                VStack(spacing: 16) {
                    
                    VStack {
                        Text(authMode == .login ? "¿Todavía no tienes una cuenta?" : "")
                            .fontWeight(.light)
                        Button {
                            withAnimation(.easeIn) {
                                authMode = authMode == .login ? .signup : .login
                            }
                        } label: {
                            Text(authMode == .login ? "Regístrate" : "Tengo cuenta")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.dirtyWhite)
                }
            }
        }
        .padding()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func authAction() {
        // TODO: Añadir validación de campos antes de ejecutar la acción
        Task {
            do {
                isLoading = true
                if authMode == .login {
                    self.account = try await auth.signIn(email: email, password: password)
                    flow = .authenticated
                } else {
                    self.account = try await auth.signUp(email: email, password: password)
                    flow = .authenticated
                }
            } catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthenticationView(account: .constant(nil), flow: .constant(.unauthenticated))
        .environment(AuthService())
        .background(.customBlack)
}

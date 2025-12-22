//
//  AuthenticationView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import SwiftUI
import Supabase
import RevenueCat

enum AuthMode {
    case login
    case signup
    case resetPassword
}

struct AuthenticationView: View {
    
    @Environment(AuthService.self) var auth

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var authMode: AuthMode = .login
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Group {
                switch authMode {
                case .login:
                    SignInForm(
                        email: $email,
                        password: $password,
                        isLoading: $isLoading,
                        authMode: $authMode
                    )
                case .signup:
                    SignUpForm(
                        email: $email,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        isLoading: $isLoading
                    )
                case .resetPassword:
                    ResetPasswordScreen(
                        authMode: $authMode,
                        isLoading: $isLoading
                    )
                }
            }
            VStack(spacing: 24) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.orange)
                        .font(.system(size: 12))
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
        .frame(maxHeight: .infinity)
        .padding()
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    AuthenticationView()
        .environment(AuthService())
        .background(.customBlack)
}

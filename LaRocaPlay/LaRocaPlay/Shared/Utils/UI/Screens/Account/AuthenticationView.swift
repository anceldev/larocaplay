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
    @Environment(AuthManager.self) var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var authMode: AuthMode = .login
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation(.easeIn) {
                        switch authMode {
                        case .login:
                            break
                        case .signup, .resetPassword:
                            self.authMode = .login
                        }
                    }
                } label: {
                    Circle()
                        .fill(Color.dirtyWhite.opacity(0.4))
                        .frame(width: 32, height: 32)
                        .overlay(alignment: .center) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10)
                                .foregroundStyle(.customBlack)
                        }
                }
                .opacity(self.authMode == .login ? 0 : 1)
                .disabled(self.authMode == .login)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Circle()
                        .fill(Color.dirtyWhite.opacity(0.4))
                        .frame(width: 32, height: 32)
                        .overlay(alignment: .center) {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16)
                                .foregroundStyle(.customBlack)
                        }
                }
            }
            Spacer()
            VStack(spacing: 32) {
                VStack {
                    switch authMode {
                    case .login:
                        SignInForm(authMode: $authMode)
                    case .signup:
                        SignUpForm(authMode: $authMode)
                    case .resetPassword:
                        ResetPasswordScreen(authMode: $authMode)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
//        .frame(maxHeight: .infinity)
        .padding(18)
        .background(.customBlack)
        .enableInjection()
    }
    private func startAsGuest() {
        Task {
            await authManager.startGuestSession()
        }
    }
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    AuthenticationView()
//        .environment(AuthService())
        .background(.customBlack)
}

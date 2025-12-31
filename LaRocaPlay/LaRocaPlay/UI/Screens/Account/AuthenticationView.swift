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
    
//    @Environment(AuthService.self) var auth
    @Environment(AuthManager.self) var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var authMode: AuthMode = .login
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            HStack {
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
            NavigationStack {
                SignInForm()
                    .background(.customBlack)
            }
//            VStack(spacing: 24) {
//                if let errorMessage {
//                    Text(errorMessage)
//                        .foregroundStyle(.orange)
//                        .font(.system(size: 12))
//                }
//                Button {
//                    startAsGuest()
//                } label: {
//                    Text("Empezar como invitado")
//                }
//            }
        }
        .frame(maxHeight: .infinity)
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

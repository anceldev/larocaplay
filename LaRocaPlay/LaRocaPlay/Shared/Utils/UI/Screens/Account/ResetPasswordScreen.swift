//
//  ResetPasswordScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import SwiftUI

struct ResetPasswordScreen: View {
    @Environment(AuthManager.self) var authManager
    @State private var email: String = ""
    @Binding var authMode: AuthMode
    var body: some View {
        VStack(spacing: 32) {
            ResetPasswordForm()
            VStack(spacing: 16) {
                VStack {
                    Button {
                        self.email = ""
                        withAnimation(.easeIn) {
                            self.authMode = .signup
                        }
                    } label: {
                        Text("Iniciar sesión")
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.plain)
                    .disabled(authManager.isLoading)
                }
                .font(.system(size: 14))
                .foregroundStyle(.dirtyWhite)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
        
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

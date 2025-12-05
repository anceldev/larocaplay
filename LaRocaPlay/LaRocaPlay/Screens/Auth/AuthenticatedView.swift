//
//  AuthenticatedView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/8/25.
//

import SwiftUI
import RevenueCat
import ConfidentialKit

struct AuthenticatedView: View {
    
    @Environment(AuthService.self) var auth
    @Binding var account: User?
    @State private var authState: AuthState
    @State private var errorMessage: String?
    
    init(account: Binding<User?>) {
        self._account = account
        self.authState = account.wrappedValue == nil ? .unauthenticated : .authenticated
    }
    
    var body: some View {
        Group {
            switch authState {
            case .unauthenticated:
//                AuthenticationView(account: $account, authState: $authState)
//                    .environment(auth)
                Text("Unauthenticaed")
            case .authenticating:
                ProgressView()
            case .authenticated:
                AccountView(account: $account, authState: $authState)
                    .environment(auth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onAppear {
//            checkAuthStatus()
//        }
        .onChange(of: account, { oldValue, newValue in
            if newValue != nil {
                authState = .authenticated
                    Purchases.logLevel = .debug
//                Purchases.configure(withAPIKey: Secrets.$testStore, )
                Purchases.configure(withAPIKey: Secrets.$testStore, appUserID: newValue?.email)
            }
        })
        .enableInjection()
        .background(.customBlack)
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func checkAuthStatus() {
        Task {
            do {
                authState = .authenticating
//                self.account = try await auth.getSession()
                try await auth.getSession()
                authState = .authenticated
            } catch {
                self.errorMessage = error.localizedDescription
                self.authState = .unauthenticated
            }
        }
    }
}

#Preview {
    AuthenticatedView(account: .constant(PreviewData.user))
        .environment(AuthService())
}

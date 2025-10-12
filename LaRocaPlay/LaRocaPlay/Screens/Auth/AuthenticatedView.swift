//
//  AuthenticatedView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/8/25.
//

import SwiftUI

enum AuthFlow {
    case unauthenticated
    case authenticating
    case authenticated
}

struct AuthenticatedView: View {
    
    @Environment(AuthService.self) var auth
    @Binding var account: User?
    @State private var flow: AuthFlow
    @State private var errorMessage: String?
    
    init(account: Binding<User?>) {
        self._account = account
        self.flow = account.wrappedValue == nil ? .unauthenticated : .authenticated
    }
    
    var body: some View {
        Group {
            switch flow {
            case .unauthenticated:
                AuthenticationView(account: $account, flow: $flow)
                    .environment(auth)
            case .authenticating:
                ProgressView()
            case .authenticated:
                AccountView(account: $account, flow: $flow)
                    .environment(auth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onAppear {
//            checkAuthStatus()
//        }
        .onChange(of: account, { oldValue, newValue in
            if newValue != nil {
                flow = .authenticated
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
                flow = .authenticating
                self.account = try await auth.getSession()
                flow = .authenticated
            } catch {
                self.errorMessage = error.localizedDescription
                self.flow = .unauthenticated
            }
        }
    }
}

#Preview {
    AuthenticatedView(account: .constant(PreviewData.user))
        .environment(AuthService())
}

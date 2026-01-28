//
//  AccountCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/11/25.
//

import SwiftUI

struct AccountCard: View {
    @Environment(AuthManager.self) var authManager
    @Environment(AppRouter.self) var router
    let user: UserProfile
    @Binding var showPaywall: Bool
    
    var body: some View {
        VStack {
            Button {
                router.navigateTo(.userDetails(user))
            } label: {
                VStack(spacing: 12) {
                    Image(.avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 88)
                        .background(.white.opacity(0.3))
                        .clipShape(.circle)
                    VStack(alignment: .center, spacing: 6) {
                        Text(user.displayName ?? "NO-NAME")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.appLabel.primary)
                        Text(user.email ?? "email")
                            .font(.system(size: 17))
                            .foregroundStyle(.appLabel.secondary)
                    }
                    Text(authManager.isSubscriptionActive ? "Plan Premium" : "Plan Gratuito")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(authManager.isSubscriptionActive ? .customRed : .customGray)
                        .foregroundStyle(authManager.isSubscriptionActive ? .white : .customBlack)
                        .mask(RoundedRectangle(cornerRadius: 20))
                    
                }
                .padding(Theme.Padding.normal)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.appBackground.secondary)
                .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
            }
            if !authManager.isSubscriptionActive {
                Button {
                    showPaywall = true
                } label: {
                    VStack {
                        Text("¡Pásate a Premium!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.appLabel.primary)
                        Text("Disfruta de todo el contenido para tu crecimiento espiritual pasándote al plan premium. Podrás acceder a las predicaiones, series, capacitaciones y mucho más")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 14, weight: .light, design: .rounded))
                            .foregroundStyle(.appLabel.primary.opacity(0.8))
                    }
                    .padding(Theme.Padding.normal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.appBackground.secondary)
                    .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

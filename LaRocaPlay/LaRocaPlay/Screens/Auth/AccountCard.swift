//
//  AccountCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/11/25.
//

import SwiftUI

struct AccountCard: View {
//    let user: User
//    let user: ProfileDTO
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 12) {
            Image(.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 88)
                .background(.white.opacity(0.3))
                .clipShape(.circle)
            VStack(alignment: .center, spacing: 6) {
                Text(user.displayName ?? "NO-NAME")
                    .font(.system(size: 20))
                Text(user.email ?? "email")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(Theme.Padding.normal)
        .background(.black.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .enableInjection()
    }
    
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}


                        

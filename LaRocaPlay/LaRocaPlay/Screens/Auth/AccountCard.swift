//
//  AccountCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/11/25.
//

import SwiftUI

struct AccountCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 12) {
            Image(.user)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 72)
                .padding(16)
                .background(.white.opacity(0.3))
                .clipShape(.circle)
            VStack(alignment: .center, spacing: 6) {
                Text(user.name)
                    .font(.system(size: 20))
                Text(user.email)
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(.black.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .enableInjection()
    }
    
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}


                        

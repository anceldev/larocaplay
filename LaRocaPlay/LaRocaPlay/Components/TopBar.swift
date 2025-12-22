//
//  TopBar.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI
import AppRouter

struct TopBar: View {
    @Environment(AuthService.self) var auth
    @Environment(AppRouter.self) var router
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Image(.topbarLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button {
                        router.navigateTo(.account(userId: auth.user?.id.uuidString ?? "NIL"))
                    } label: {
                        Image(.user)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28)
                            .foregroundStyle(.customRed)
                    }
                }
            }
            .frame(height: 38)
            HStack(spacing: 4) {
                Text("Bienvenido, ")
                Text("\(auth.user?.email ?? "invitado")")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .font(.system(size: 12))
        }
        .padding(.horizontal)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    TopBar()
}

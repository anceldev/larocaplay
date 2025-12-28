//
//  ProfileScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 20/12/25.
//

import SwiftUI

struct ProfileScreen: View {
//    @Environment(AuthService.self) var auth
    var body: some View {
        VStack {
            TopBarScreen(title: "Información de perfil", true)
            VStack {
                Text("Esta es la pantalla de perfil")
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal)
        .background(.customBlack)
        .frame(maxWidth: .infinity)
        .refreshable {
            print("Refreshing screen")
        }
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

#Preview {
    ProfileScreen()
}

//
//  ProfileView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct ProfileView: View {
//    var account: User
    var body: some View {
        // TODO: Datos del usuario
        // TODO: Datos de membresía del usuario
        Text("Profile view")
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

//#Preview {
//    ProfileView(account: PreviewData.user)
//}

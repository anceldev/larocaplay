//
//  UpdatePasswordScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/1/26.
//

import SwiftUI

struct UpdatePasswordScreen: View {
    var body: some View {
        VStack {
            UpdatePasswordForm()
                .padding(.top, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(18)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

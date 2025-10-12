//
//  SettingsView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 11/9/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Ajustes")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.customBlack)
            
            Spacer()
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    SettingsView()
}

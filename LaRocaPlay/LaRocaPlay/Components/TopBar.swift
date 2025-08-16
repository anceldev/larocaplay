//
//  TopBar.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI
import AppRouter

struct TopBar: View {
    var body: some View {
        HStack {
            Button {
                print("Go to notifications")
            } label: {
                Image(systemName: "bell")
            }
            Spacer()
            Text("Title")
            Spacer()
            Button {
                print("Go to profile to auth")
            } label: {
                Image(systemName: "person")
            }

        }
        .padding(.horizontal)
    }
}

#Preview {
    TopBar()
}

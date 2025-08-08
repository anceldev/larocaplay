//
//  ContentView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            TopBar()
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                            .tint(Color.customRed)
                    }
                PreachesView()
                    .tabItem {
                        Image(systemName: "book")
                            .tint(Color.customRed)
                    }
                StoreView()
                    .tabItem {
                        Image(systemName: "cart")
                            .tint(Color.customRed)
                    }
            }
        }
    }
}


#Preview {
    ContentView()
        .environment(AWService())
}

//
//  ContentView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AppRouter
import SwiftUI

struct ContentView: View {
    @State private var router = Router<AppTab, Destination, Sheet>(initialTab: .home)
    
    var body: some View {
        VStack {
            topBar()
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack(path: $router[tab]) {
                        Group {
                            switch tab {
                            case .home:
                                HomeView()
                            case .preaches:
                                PreachesView()
                            case .store:
                                StoreView()
                            }
                        }
                        .navigationDestination(for: Destination.self) { destination in
                            destinationView(for: destination)
                        }
                    }
                    .tabItem {
                        Label(tab.rawValue.capitalized, systemImage: tab.icon)
                    }
                    .tag(tab)
                }
            }
            .tint(Color.customRed)
            .sheet(item: $router.presentedSheet) { sheet in
                sheetView(for: sheet)
            }
        }
        .background(.dirtyWhite)
    }
    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            Button {
                router.presentSheet(.settings)
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(.customRed)
            }
            Spacer()
            Text("Larocaplay")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.customBlack)
            Spacer()
            Button {
                router.presentSheet(.profile)
            } label: {
                Image(systemName: "person")
                    .foregroundStyle(.customRed)
            }

        }
        .frame(height: 40)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .preach(let id):
            Text("Preach view \(id)")
        case .list:
            Text("List view")
        case .account(let userId):
            Text("Account view: \(userId)")
        case .userDetail(let id):
            Text("User details view: \(id)")
        case .postDetail(let id):
            Text("Post details view: \(id)")
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .settings:
            Text("Settings view")
        case .profile:
            Text("Profile view")
        case .compose:
            Text("Compose view")
        }
    }
}


#Preview {
    ContentView()
        .environment(AWService())
}

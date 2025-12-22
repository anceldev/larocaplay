//
//  MainScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AppRouter
import SwiftUI
@_exported import Inject

typealias AppRouter = Router<AppTab, Destination, Sheet>

struct MainScreen: View {
    @Environment(AuthService.self) var auth
    @Environment(PreachesRepository.self) var repository
    @Environment(CollectionRepository.self) var collections

    
    @State private var router = AppRouter(initialTab: .home)
    @State var account: Profile?
    
    @ObserveInjection var forceRedraw
    
    var body: some View {
        VStack {
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack(path: $router[tab]) {
                        Group {
                            switch tab {
                            case .home:
                                HomeView()
                            case .preaches:
                                PreachesScreen(collectionId: 1)
                            case .training:
                                DiscipleshipListScreen()
                            case .karaoke:
                                MusicScreen()
                            }
                        }
                        .navigationDestination(for: Destination.self) { destination in
                            destinationView(for: destination)
                        }
                    }
                    .tabItem {
                        Label(tab.label.capitalized, image: tab.icon)
                            .font(.system(size: 40))
                            .labelStyle(.iconOnly)
                    }
                    .tag(tab)
                }
            }
            .tint(Color.customRed)
            .sheet(item: $router.presentedSheet) { sheet in
                sheetView(for: sheet)
            }
        }
        .background(.customBlack)
        .environment(router)
        #if DEBUG
        .enableInjection()
        #endif
    }
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .preach(let item):
            PreachScreen(preach: item)
        case .preacher(let preacher):
            PreacherScreen(preacher: preacher)
        case .list:
            Text("List view")
        case .account(let userId):
            AccountScreen()
                .navigationBarBackButtonHidden()
        case .userDetail:
            ProfileScreen()
                .navigationBarBackButtonHidden()
        case .postDetail(let id):
            Text("Post details view: \(id)")
        case .congresses:
            CongressesScreen()
        case .series:
            SeriesScreen()
                .navigationBarBackButtonHidden()
        case .serie(let serieId):
            SerieScreen(serieId: serieId)
        case .collection(let id, let cols):
            CollectionScreen(collectionId: id)
                .navigationBarBackButtonHidden()
        case .subscription:
            SubscriptionScreen()
                .navigationBarBackButtonHidden()
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .settings:
            SettingsView(account: $account)
        case .profile:
            Text("Profile view")
        case .compose:
            Text("Compose view")
        case .auth:
//            AuthenticatedView(account: $account)
            Text("Auth state")
        }
    }
}


#Preview {
    MainScreen()
        .environment(AWService())
        .environment(AuthService())
        .environment(PreachesRepository())
}

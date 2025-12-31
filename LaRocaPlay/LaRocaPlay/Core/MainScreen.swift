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
    @State private var router = AppRouter(initialTab: .home)
    
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
//                                PreachesScreen(collectionId: 1)
                                CollectionDetailScreen(collectionId: 1, order: .date, backButton: false)
                            case .training:
                                DiscipleshipListScreen()
                            case .karaoke:
                                Text("Music screen")
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
        case .account:
            AccountScreen()
                .navigationBarBackButtonHidden()
        case .userDetails(let profile):
            UserDetailsScreen(userProfile: profile)
                .navigationBarBackButtonHidden()
        case .postDetail(let id):
            Text("Post details view: \(id)")
        case .congresses:
            CongressesScreen()
        case .serie(let serieId):
            SerieScreen(serieId: serieId)
        case .collections(let typeName, let title):
            CollectionsScreen(typeName: typeName, title: title)
                .navigationBarBackButtonHidden()
        case .collection(let id):
            CollectionDetailScreen(collectionId: id, order: .position)
                .navigationBarBackButtonHidden()
        case .subscription:
            SubscriptionScreen()
                .navigationBarBackButtonHidden()
        case .resetPassword:
            ResetPasswordScreen(authMode: .constant(.resetPassword))
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .settings:
            Text("Settings View")
        case .profile:
            Text("Profile view")
        case .compose:
            Text("Compose view")
        case .auth:
            Text("Auth state")
        }
    }
}


#Preview {
    MainScreen()
        .environment(AuthManager(service: AuthService()))
}

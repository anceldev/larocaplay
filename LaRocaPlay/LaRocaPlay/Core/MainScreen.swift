//
//  MainScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AppRouter
@_exported import Inject
import SwiftUI

typealias AppRouter = Router<AppTab, Destination, Sheet>

struct MainScreen: View {
    @Environment(AuthManager.self) var authManager
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
                                CollectionContainerView(
                                    collectionId: 1,
                                    isDeepLink: false
                                )
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
        .background(.appBackground.primary)
        .environment(router)
        .onAppear {
            if let pendingUrl = authManager.pendingDeepLink {
                router.navigate(to: pendingUrl)
                authManager.pendingDeepLink = nil
            }
        }
        .onOpenURL { url in
            if url.scheme == "larocaplayapp" {
                router.navigate(to: url)
            }
        }
#if DEBUG
        .enableInjection()
#endif
    }
}

extension MainScreen {
    
    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .preachDetail(let id, let isDeepLink):
            PreachContainerView(itemId: id, isDeepLink: isDeepLink)
                .navigationBarBackButtonHidden()
        case .preacher(let preacher):
            PreacherScreen(preacher: preacher)
        case .account:
            AccountScreen()
                .navigationBarBackButtonHidden()
        case .userDetails(let profile):
            UserDetailsScreen(userProfile: profile)
                .navigationBarBackButtonHidden()
        case .collections(let typeName, let title):
            CollectionsScreen(typeName: typeName, title: title)
                .navigationBarBackButtonHidden()
        case .collection(let id, let isDeepLink):
            //            CollectionDetailScreen(collectionId: id, isDeepLink:  order: .position)
            CollectionContainerView(collectionId: id, isDeepLink: isDeepLink)
                .navigationBarBackButtonHidden()
        case .resetPassword:
            ResetPasswordScreen(authMode: .constant(.resetPassword))
        case .aboutUs:
            AboutUsScreen()
                .navigationBarBackButtonHidden()
        case .notificationSettings:
            UserNotificationSettingsScreen()
                .navigationBarBackButtonHidden()
        case .myNotifications:
            Text("Mis notificaciones")
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

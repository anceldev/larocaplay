//
//  ContentView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AppRouter
import SwiftUI
@_exported import Inject

typealias AppRouter = Router<AppTab, Destination, Sheet>

struct ContentView: View {
    @State private var router = AppRouter(initialTab: .home)
    @Environment(AuthService.self) var authService
    @Environment(PreachesRepository.self) var repository
    @State var account: User?
    
    @ObserveInjection var forceRedraw
    
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
                                PreachesView(account: $account, preaches: repository.preaches)
                            case .training:
                                DiscipleshipListScreen(role: account?.role ?? .member)
                            case .karaoke:
                                MusicScreen()
                            case .store:
                                StoreView()
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
        .onAppear(perform: {
            self.account = authService.user
        })
        .background(.customBlack)
        .environment(router)
        #if DEBUG
        .enableInjection()
        #endif
    }
    @ViewBuilder
    private func topBar() -> some View {
        VStack {
            HStack {
                Button {
                    router.presentSheet(.settings)
                } label: {
                    Image("gear-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .foregroundStyle(.customRed)
                        
                }
                Spacer()
                Image(.topbarLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                Spacer()
                Button {
                    router.presentSheet(.auth)
                } label: {
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .foregroundStyle(.customRed)
                }
                
            }
            .frame(height: 38)
            HStack(spacing: 4) {
                Text("Bienvenido,")
                    .foregroundStyle(.dirtyWhite)
                Text("\(account?.email ?? "invitado")")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .font(.system(size: 12))
        }
        .padding(.horizontal)
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
            Text("Account view: \(userId)")
        case .userDetail(let id):
            Text("User details view: \(id)")
        case .postDetail(let id):
            Text("Post details view: \(id)")
        case .congresses:
            CongressesScreen()
        case .series:
            SeriesScreen()
        case .serie(let serieId):
            SerieScreen(serieId: serieId)
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .settings:
            SettingsView()
        case .profile:
            Text("Profile view")
        case .compose:
            Text("Compose view")
        case .auth:
            AuthenticatedView(account: $account)
        }
    }
}


#Preview {
    ContentView()
        .environment(AWService())
        .environment(AuthService())
        .environment(PreachesRepository())
}

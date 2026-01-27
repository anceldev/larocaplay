//
//  SwiftUIView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 23/1/26.
//

import SwiftUI

struct UserNotificationSettingsScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context
    var body: some View {
        VStack {
            TopBarScreen(title: "Notificaciones", true)
            ScrollView(.vertical) {
                if let user = authManager.currentUserProfile,
                   let settings = user.notificationSettings {
                    @Bindable var bindableSettings = settings
                    VStack(spacing: 24) {
//                        VStack(spacing: 10) {
//                            Text("Mis Notificaciones")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .font(.system(size: 16))
//                                .fontWeight(.semibold)
//                                .padding(.leading, 6)
//                            VStack(spacing: 16) {
//                                Button {
//                                    router.navigateTo(.myNotifications)
//                                } label: {
//                                    HStack {
//                                        Image(.bell)
//                                        Text("Notificaciones")
//                                        Spacer()
//                                    }
//                                    .foregroundStyle(.white)
//                                }
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                            .padding()
//                            .background(.black.opacity(0.45))
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                        }
                        VStack(spacing: 10) {
                            Text("Preferencias")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 6)
                            VStack(spacing: 16) {
                                Toggle(isOn: $bindableSettings.newMainCollectionItem) {
                                    HStack {
                                        Text("Nueva predicación")
                                        Spacer()
                                    }
                                    .foregroundStyle(.dirtyWhite)
                                }
                                .tint(.customRed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Toggle(isOn: $bindableSettings.newPublicCollection) {
                                    HStack {
                                        Text("Nueva serie")
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Toggle(isOn: $bindableSettings.newPrivateCollection){
                                    HStack {
                                        Text("Nueva serie privada")
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Toggle(isOn: $bindableSettings.newPublicCollectionItem){
                                    HStack {
                                        Text("Nueva predicación en serie")
                                        Spacer()
                                    }
                                }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Toggle(isOn: $bindableSettings.newPrivateCollectionItem){
                                        HStack {
                                            Text("Nueva predicación en serie privada")
                                            Spacer()
                                        }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Toggle(isOn: $bindableSettings.youtubeLive){
                                    HStack {
                                        Text("Nueva emisión en directo")
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(.black.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                } else {
                    ProgressView("Cargando ajustes de notificaciones")
                        .tint(.customRed)
                }
            }
            .scrollIndicators(.hidden)
        }
        
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
        .onDisappear {
            if context.hasChanges {
                if let settings = authManager.currentUserProfile?.notificationSettings {
                    try? context.save()
                    Task {
                        await NotificationManager.shared.saveSettingsToServer(settings)
                    }
                }
            }
        }
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

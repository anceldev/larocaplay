//
//  PreachView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import Foundation
import SwiftUI
import RevenueCatUI

struct PreachView: View {
    
    @Environment(AppRouter.self) var router
    @Environment(AuthManager.self) var authManager
//    @Environment(AuthService.self) var auth
//    @Environment(CollectionRepository.self) var collections
    @State private var showPaywall = false
    @State private var errorMessage: String? = nil
    var preach: PreachDTO

    
    let spanishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE d 'de' MMMM 'de' y"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                VStack {
//                    if auth.isPremium {
//                        VimeoVideoPlayer(for: preach.videoUrl)
//                        VimeoEmbedPlayer(videoURL: preach.videoUrl)
//                            .aspectRatio(16/9, contentMode: .fit)
//                    } else {
                        ZStack {
                            Color.black
                            VStack {
                                Text("Necesitas estar suscrito para ver este contenido")
                                    .multilineTextAlignment(.center)
                                Button {
                                    self.showPaywall = true
                                } label: {
                                    Text("Suscribirme")
                                        .underline(true)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fill)
//                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .customBlack.opacity(0.5), radius: 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        VStack(alignment: .leading) {
                            Text(preach.title)
                                .font(.system(size: 24))

                                //                            if let preacher = preach.preacher {
                                Button {
                                    router.navigateTo(.preacher(preacher: preach.preacher))
                                } label: {
                                    
                                    HStack(spacing: 4) {
                                        Text(preach.preacher.role.name)
                                        Text(preach.preacher.name)
                                            .underline(true, color: .customBlack.opacity(0.5))
                                    }
                                    .foregroundStyle(.customBlack.opacity(0.8))
                                    .font(.system(size: 16))
                                }
                                //                            }
                            
                        }
                        Text(spanishDateFormatter.string(from: preach.date))
                            .font(.system(size: 14))
                    }
                    if let description = preach.description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showPaywall, content: {
            PaywallView()
        })
        .onChange(of: showPaywall) { oldValue, newValue in
            if newValue == false {
                getCustomerInfo()
            }
        }
        .padding()
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func getCustomerInfo() {
//        Task {
//            do {
//                guard let userId = auth.user?.id else {
//                    return
//                }
//                try await auth.getSuscriptionStatus(userId: userId.uuidString)
////                collections.series.removeAll()
//            } catch {
//                print(error.localizedDescription)
//                self.errorMessage = error.localizedDescription
//            }
//        }
    }
}

//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI
import RevenueCatUI

struct PreachScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(PreachesRepository.self) var preaches
    @Environment(AuthService.self) var auth
//    @Environment(CollectionRepository.self) var collections
    @State private var videoURL: URL?
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false

    var preach: Preach
    
    let spanishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
//        formatter.dateFormat = "EEEE d 'de' MMMM 'de' y"
        formatter.dateFormat = "d / MMMM / y"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                VStack {
//                    if !auth.isPremium {
//                        ZStack {
//                            Color.black
//                            VStack {
//                                Text("Necesitas estar suscrito para ver este contenido")
//                                    .multilineTextAlignment(.center)
//                                Button {
//                                    self.showPaywall = true
//                                } label: {
//                                    Text("Suscribirme")
//                                        .underline(true)
//                                }
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
////                        .aspectRatio(16/9, contentMode: .fill)
//                    } else {
//                        if let videoURL {
                            VimeoVideoPlayer(preach: preach)
//                        }
//                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .customBlack.opacity(0.5), radius: 10)
//                .border(.yellow, width: 1)
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        VStack(alignment: .leading) {
                            Text(preach.title)
                                .font(.system(size: 24))
                         }
                        Text(spanishDateFormatter.string(from: preach.date))
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .border(.red, width: 1)
                    if let description = preach.desc {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .background(.customBlack)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.popNavigation()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
//                        Text("Atrás")
//                            .foregroundStyle(.customRed)
                    }
                }
            }
        })
        .sheet(isPresented: $showPaywall, content: {
            PaywallView()
        })
        .onChange(of: showPaywall) { oldValue, newValue in
            if newValue == false {
                getCustomerInfo()
            }
        }
//        .onAppear(perform: {
//            loadVideoURL()
//        })
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
//    private func loadVideoURL() {
//        Task {
//            do {
//                self.videoURL = try await VimeoService.shared.getVideoURL(for: preach.videoId)
//            } catch {
//                print(error)
//                print(error.localizedDescription)
//                self.errorMessage = "Ha ocurrido un error al cargar la predicación"
//            }
//        }
//    }
    private func getCustomerInfo() {
        Task {
            do {
                guard let userId = auth.user?.id else {
                    return
                }
                try await auth.getSuscriptionStatus(userId: userId.uuidString)
//                collections.series.removeAll()
            } catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }


}

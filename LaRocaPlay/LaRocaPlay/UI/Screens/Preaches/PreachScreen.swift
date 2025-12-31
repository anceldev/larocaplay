//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI
import MediaPlayer
import RevenueCatUI

struct PreachScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(LibraryManager.self) var libManager
    @State private var videoUrl: URL?
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false
    @State private var isLoading = false

    @State private var showVideo = false
    
    
    var preach: Preach
    
    let spanishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d / MMMM / y"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            TopBarScreen(title: preach.title, true)
            ScrollView(.vertical) {
                ZStack(alignment: .center) {
                    ThumbImageLoader(storageCollection: .preaches(preach.imageId))
                        .overlay(alignment: .bottomTrailing) {
                            if let _ = videoUrl {
                                Button {
                                    showVideo = true
                                } label: {
                                    Label {
                                        Text("Ver ahora")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                    } icon: {
                                        Circle()
                                            .tint(.white.opacity(0.9))
                                            .frame(width: 30)
                                            .overlay(alignment: .center) {
                                                
                                                Image(.halfDottedCirclePlay)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 28)
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.thinMaterial.opacity(0.8))
                                .mask(RoundedRectangle(cornerRadius: 50))
                                .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 0)
                                .padding(.bottom, 8)
                                .padding(.trailing, 8)
                            } else {
                                Button {
                                    print("Video no disponible. No action")
                                } label: {
                                    Label {
                                        Text("No disponible")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                    } icon: {
                                        Image(.triangleWarning)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28)
                                            .tint(.yellow)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.thinMaterial.opacity(0.8))
                                .mask(RoundedRectangle(cornerRadius: 50))
                                .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 0)
                                .padding(.bottom, 8)
                                .padding(.trailing, 8)
                            }
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .customBlack.opacity(0.5), radius: 10)
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
//        .toolbar(content: {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    router.popNavigation()
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                            .foregroundStyle(.white)
//
//                    }
//                }
//            }
//        })
        .sheet(isPresented: $showPaywall, content: {
            PaywallView()
        })
        .sheet(
            isPresented: $showVideo,
            content: {
                PlayerContainerView(
                    title: preach.title,
                    artist: preach.preacher?.name,
                    videoURL: videoUrl!
                )
                .presentationDragIndicator(.visible)

        })
        .onAppear(perform: {
            Task {
                await loadVideoURL()
            }
        })
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func loadVideoURL() async {
        isLoading = true
        do {
                let url = try await libManager.getValidVideoUrl(for: preach)
                self.videoUrl = url
        } catch {
            print("ERROR: Error cargando video \(error)")
            errorMessage = "No pudimmos conectar con el servidor del video"
            self.isLoading = false
        }
    }
}

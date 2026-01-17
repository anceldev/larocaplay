//
//  PreachDetailView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 14/1/26.
//

import SwiftUI
import RevenueCatUI

struct PreachDetailView: View {
    @Environment(AppRouter.self) var router
    @Environment(AuthManager.self) var authManager
    @Environment(LibraryManager.self) var libManager
    @State private var videoUrl: URL?
    @State private var errorMessage: String? = nil
    @State private var showPaywall = false
    @State private var isLoading = false
    @State private var showVideo = false
    @State private var isDescriptionExpanded = false
    
//    let preach: Preach
    let item: CollectionItem
    
    let spanishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d/MMMM/y"
        return formatter
    }()
    
    var itemUrl: URL? {
        guard let preach = item.preach, let collection = item.collection else {
            return nil
        }
        let urlString = "larocaplayapp://collection/\(collection.id)/preach/\(preach.id)"
        return URL(string: urlString)!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let preach = item.preach {
                TopBarScreen(title: preach.title, true)
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        ZStack(alignment: .center) {
                            if authManager.isSubscriptionActive {
                                ThumbImageLoader(storageCollection: .preaches(preach.imageId))
                                    .overlay(alignment: .bottomTrailing) {
                                        if let _ = videoUrl {
                                            ShowNowButton(button: $showVideo)
                                        } else {
                                            UnavailableVideoButton(isLoading: isLoading)
                                        }
                                    }
                            } else {
                                SubscriptionCard(button: $showPaywall)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(height: nil)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .customBlack.opacity(0.5), radius: 10)
                        .animation(.smooth, value: authManager.isSubscriptionActive)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .center) {
                                VStack(alignment: .center) {
                                    Text(preach.title)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .multilineTextAlignment(.center)
                                }
                                Text(spanishDateFormatter.string(from: preach.date))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            //                    .border(.red, width: 1)
                            if let description = preach.desc {
                                VStack {
                                    Text(description)
                                        .foregroundStyle(.dirtyWhite)
                                        .font(.system(size: 14))
                                        .padding(.horizontal, 6)
                                    //                                    .multilineTextAlignment(.center)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(isDescriptionExpanded ? nil : 3)
                                    Text(isDescriptionExpanded ? "Leer menos" : "Leer más...")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.customRed)
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)){
                                        isDescriptionExpanded.toggle()
                                    }
                                }
                            }
                            Spacer()
                            if let itemUrl {
                                HStack {
                                    ShareLink(
                                        item: itemUrl,
                                        subject: Text("Mira esta predicación"),
                                        message: Text("\(preach.title) - \(preach.preacher?.name ?? "")")) {
                                            Image(.paperPlane2)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                                .foregroundStyle(.white)
                                                .padding(8)
//                                                .mask {
//                                                    Circle()
//                                                        .border(.white.opacity(0.3), width: 1)
//                                                }
//                                                .overlay {
//                                                    Circle()
//                                                        .stroke(.white.opacity(0.3), lineWidth: 1)
//                                                }
                                        }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    loadVideoURL()
                }
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
                .sheet(isPresented: $showPaywall, content: {
                    PaywallView()
                        .onPurchaseCompleted { customerInfo in
                            authManager.customerInfo = customerInfo
                            loadVideoURL()
                        }
                })
            } else {
                Text("Error desconocido al cargar la enseñanza")
            }
        }
        .onAppear {
            loadVideoURL()
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func loadVideoURL() {
        guard authManager.isSubscriptionActive else { return }
        guard let preach = item.preach else { return }
        isLoading = true
        defer { isLoading = false }
        Task {
            do {
                let url = try await libManager.getValidVideoUrl(for: preach)
                self.videoUrl = url
            } catch {
                print("ERROR: Error cargando video \(error)")
                errorMessage = "No pudimmos conectar con el servidor del video"
            }
        }
    }
}

struct SubscriptionCard: View {
    @Environment(AuthManager.self) var authManager
    @Binding var button: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .aspectRatio(16/9, contentMode: .fill)
            VStack(spacing: 18) {
                VStack(spacing: 8) {
//                    Text("Sin suscripción")
//                        .bold()
                    Text(authManager.isSubscriptionActive ? "Plan Premium" : "Plan Gratuito")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(authManager.isSubscriptionActive ? .customRed : .customGray)
                        .foregroundStyle(authManager.isSubscriptionActive ? .white : .customBlack)
                        .mask(RoundedRectangle(cornerRadius: 20))
                    Text("Este contenido sólo está disponible en el **Plan Premium**.\nAl suscribirte, tendrás acceso a ello además de series y capacitaciones para tu crecimiento espiritual.")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                }
                Button {
                    button = true
                } label: {
                    Text("Suscribirme")
//                        .underline()
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.customRed.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay {
                            Capsule()
                                .stroke(.customRed.opacity(0.8), lineWidth: 1)
                        }
                }
            }
        }
        .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
struct ShowNowButton: View {
    @Binding var button: Bool
    var body: some View {
        Button {
            button = true
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
    }
}

struct UnavailableVideoButton: View {
    var isLoading: Bool
    var body: some View {
        Button {
            print("Video no disponible. No action")
        } label: {
            Label {
                Text(isLoading ? "Cargando" : "No disponible")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            } icon: {
                if isLoading {
                    ProgressView()
                        .tint(.customRed)
                        .frame(width: 28)
                } else {
                    Image(.triangleWarning)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .tint(.yellow)
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
    }
}


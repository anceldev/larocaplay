//
//  OnboardingScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/11/25.
//

import SwiftUI

struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var image: String
}
let cards: [Card] = [
    .init(image: "Pic 1"),
    .init(image: "Pic 2"),
    .init(image: "Pic 3"),
    .init(image: "Pic 4"),
]


struct OnboardingScreen: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(NetworkMonitor.self) private var network
    @State private var activeCard: Card? = cards.first
    @State private var scrollView: UIScrollView?
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var titleProgress: CGFloat = 0
    @State private var showAuthView = false
    var navigationState: AuthNavigationState
    var isServerDisabled: Bool {
        authManager.serviceStatus == .serverMaintenance
    }
    
    var body: some View {
        ZStack {
            /// Ambient Background View
            AmbientBackground()
                .animation(.easeInOut(duration: 1), value: activeCard)
            
            VStack(spacing: 40) {
                InfiniteScrollView(collection: cards) { card in
                    CarouselCardView(card)
                } uiScrollView: {
                    scrollView = $0
                } onScroll: {
                    updateActiveCard()
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
                .containerRelativeFrame(.vertical) { value, _ in
                    value * 0.45
                }
                .visualEffect { [initialAnimation] content, proxy in
                    content
                        .offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
                }

                VStack(spacing: 4) {
                    Text("Bienvenido a")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                    
                    Group {
                        if #available(iOS 18, *) {
                            Text("La Roca Play")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .textRenderer(TitleTextRenderer(progress: titleProgress))
                        } else {
                            Text("La Roca Play")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    Text("Impulsa tu crecimiento espiritual. Recuerda que la fe viene por el oir la Palabras de Dios")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                }
                if navigationState == .onboarding {
                    Button {
                        timer.upstream.connect().cancel()
                        showAuthView.toggle()
                        //// YOUR CODE
                    } label: {
                        Text("Empezar")
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(.white, in: .capsule)
                    }
                    .blurOpacityEffect(initialAnimation)
                    .disabled(!network.isConnected)
                } else {
                    ProgressView("Cargando perfil")
                        .tint(.white)
                }
                
                if !network.isConnected, let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                }
            }
            .safeAreaPadding(15)
        }
        .sheet(isPresented: $showAuthView, content: {
            NavigationStack {
                AuthenticationView()
            }
        })
        .onReceive(timer) { _ in
            if let scrollView = scrollView {
                scrollView.contentOffset.x += 0.35
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
            
            withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
                titleProgress = 1
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    func updateActiveCard() {
        if let currentScrollOffset = scrollView?.contentOffset.x {
            let activeIndex = Int((currentScrollOffset / 220).rounded()) % cards.count
            guard activeCard?.id != cards[activeIndex].id else { return }
            activeCard = cards[activeIndex]
        }
    }
    
    @ViewBuilder
    private func AmbientBackground() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(cards) { card in
                    Image(card.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .frame(width: size.width, height: size.height)
                        /// Only Showing active Card Image
                        .opacity(activeCard?.id == card.id ? 1 : 0)
                }
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
            .blur(radius: 90, opaque: true)
            .ignoresSafeArea()
        }
    }
    
    /// Carousel Card View
    @ViewBuilder
    private func CarouselCardView(_ card: Card) -> some View {
        GeometryReader {
            let size = $0.size
            
            Image(card.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
        }
        .frame(width: 220)
        .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
            content
                .offset(y: phase == .identity ? -10 : 0)
                .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
        }
    }
}

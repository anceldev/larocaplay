//
//  OfflineSupportModifier.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/1/26.
//

import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


struct OfflineSupportModifier: ViewModifier {
    
    var isConnected: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: !isConnected ? 10 : 0)
                .disabled(!isConnected)
            if !isConnected {
                BlurView(style: .systemThinMaterial)
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .transition(.opacity)
                    .zIndex(1)
                NetworkBanner()
                    .zIndex(2)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.5), value: isConnected)
    }
}
extension View {
    func supportOfflineMode(isConnected: Bool) -> some View {
        modifier(OfflineSupportModifier(isConnected: isConnected))
    }
}

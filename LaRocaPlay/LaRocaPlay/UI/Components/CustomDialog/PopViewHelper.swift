//
//  PopViewHelper.swift
//  Movix
//
//  Created by Ancel Dev account on 14/3/25.
//

import SwiftUI

fileprivate struct PopViewHelper<ViewContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var onDismiss: () -> Void
    @ViewBuilder var viewContent: ViewContent
    @State private var presentFullScreenCover: Bool = false
    @State private var animateView: Bool = false
    
    @MainActor
    var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        return .zero
    }
    
    func body(content: Content) -> some View {
        let screenHeight = screenSize.height
        let animateView = animateView
        content
            .fullScreenCover(isPresented: $presentFullScreenCover, onDismiss: onDismiss) {
                ZStack {
                    viewContent
                        .visualEffect { content, proxy in
                            content
                                .offset(y: offset(proxy, screeenHeight: screenHeight, animateView: animateView))
                        }
                        .presentationBackground(.clear)
                        .task {
                            guard !animateView else { return }
                            withAnimation(.bouncy(duration: 0.4, extraBounce: 0.05)) {
                                self.animateView = true
                            }
                        }
                        .ignoresSafeArea(.container, edges: .all)
                }
            }
            .onChange(of: isPresented) { oldValue, newValue in
                if newValue {
                    toggleView(true)
                }
                else {
                    Task {
                        withAnimation(.snappy(duration: 0.45, extraBounce: 0)) {
                            self.animateView = false
                        }
                        try await Task.sleep(for: .seconds(0.45))
                        toggleView(false)
                    }
                }
            }
            .blur(radius: isPresented ? 2 : 0)
    }
    
    nonisolated func offset(_ proxy: GeometryProxy, screeenHeight: CGFloat, animateView: Bool) -> CGFloat {
        let viewHeight = proxy.size.height
        return animateView ? 0 : (screeenHeight + viewHeight) / 2
    }
    func toggleView(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            presentFullScreenCover = status
        }
    }
}

extension View {
    @ViewBuilder
    func popView<Content: View>(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(PopViewHelper(isPresented: isPresented, onDismiss: onDismiss, viewContent: content))
    }
}

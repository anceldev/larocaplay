//
//  StreamingCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct StreamingCard: View {
    let streamingUrl: String
    @State private var isVisible: Bool = true
    var body: some View {
        ZStack {
            Image(.bannerStreaming)
                .resizable()
                .scaledToFill()
            Link(destination: URL(string: "https://www.youtube.com/@CentroCristianoLaRoca")!) {
                VStack {
                    Image(.halfDottedCirclePlay)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(.customRed)
                    //                        .overlay {
                    Text("Ver emisión en directo")
                        .shadow(color: .black, radius: 5)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                isVisible = false
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.gray)
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 8)
                .foregroundStyle(.gray.opacity(0.3))
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

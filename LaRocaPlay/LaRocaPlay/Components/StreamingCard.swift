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
                .scaledToFit()
            VStack {
                Image(.halfDottedCirclePlay)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .foregroundStyle(.dirtyWhite)
                
                Link(destination: URL(string: "https://www.youtube.com/@CentroCristianoLaRoca")!) {
                    VStack {
                        Text("Ver emisión en directo")
                            .opacity(isVisible ? 1.0 : 0.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                    isVisible = false
                                }
                            }
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
                    .shadow(color: .black,radius: 5)
                }
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
//
//#Preview {
//    StreamingCard()
//}

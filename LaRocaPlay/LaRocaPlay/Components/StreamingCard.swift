//
//  StreamingCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct StreamingCard: View {
    var body: some View {
        VStack {
            Link(destination: URL(string: "https://www.youtube.com/@CentroCristianoLaRoca")!) {
                ZStack {
                    Image(.bgStreaming)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 3)
                    VStack {
                        Text("Directo celebración")
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .shadow(color: .black,radius: 5)
                }
            }
        }
        .frame(height: 140)
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

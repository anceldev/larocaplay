//
//  ExpandableDescription.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import SwiftUI

struct ExpandableDescription: View {
    var descriptionText: String
    @State private var isTextExpanded = false
    var body: some View {
        VStack(spacing: 4) {
            Text(descriptionText)
                .foregroundStyle(.dirtyWhite)
                .font(.system(size: 14))
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .lineLimit(isTextExpanded ? nil : 3)
            Text(isTextExpanded ? "Leer menos" : "Leer más...")
                .font(.system(size: 10))
                .foregroundStyle(.customRed)
        }
        .onTapGesture {
            withAnimation(.smooth(duration: 1.2)) {
                isTextExpanded.toggle()
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

//
//  CustomCapsuleButtonStyle.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct CustomCapsuleButtonStyle: ButtonStyle {
    let bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .foregroundStyle(.white)
            .background(bgColor)
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == CustomCapsuleButtonStyle {
    static func capsuleButton(_ color: Color = .customRed) -> CustomCapsuleButtonStyle {
        CustomCapsuleButtonStyle(bgColor: color)
    }
}

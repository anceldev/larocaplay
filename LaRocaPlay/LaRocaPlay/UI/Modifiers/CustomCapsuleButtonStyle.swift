//
//  CustomCapsuleButtonStyle.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct CustomCapsuleButtonStyle: ButtonStyle {
    let bgColor: Color
    let textColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
//            .padding(.vertical)
            .foregroundStyle(textColor)
            .background(bgColor)
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == CustomCapsuleButtonStyle {
    static func capsuleButton(_ color: Color = .customRed, textColor: Color = .white) -> CustomCapsuleButtonStyle {
        CustomCapsuleButtonStyle(bgColor: color, textColor: textColor)
    }
}

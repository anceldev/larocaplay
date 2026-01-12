//
//  CustomCapsuleButtonStyle.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

enum CustomButtonSize {
  case small
  case regular

  var labeSize: CGFloat {
    switch self {
    case .small: 16
    case .regular: 20
    }
  }
}

struct CustomCapsuleButtonStyle: ButtonStyle {
  let bgColor: Color
  let textColor: Color
  let buttonSize: CustomButtonSize
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: buttonSize.labeSize, weight: .bold, design: .rounded))
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .foregroundStyle(textColor)
      .background(bgColor)
      .clipShape(.capsule)
  }
}

extension ButtonStyle where Self == CustomCapsuleButtonStyle {
  static func capsuleButton(color: Color = .customRed, textColor: Color = .white, buttonSize: CustomButtonSize = .regular
  ) -> CustomCapsuleButtonStyle {
    CustomCapsuleButtonStyle(bgColor: color, textColor: textColor, buttonSize: buttonSize)
  }
}

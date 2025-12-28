//
//  CustomTextFieldStyle.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    
    let height: CGFloat
    
    init(_ height: CGFloat = 56) {
        self.height = height
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
//            .frame(minHeight: 56)
            .frame(height: height)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
//            .foregroundStyle(.white)
            .tint(.white)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(.white, lineWidth: 1)
            }
    }
}

extension TextFieldStyle where Self == CustomTextFieldStyle {
    static var customTextFieldStyle: Self {
        CustomTextFieldStyle()
    }
    static func customTextFieldStyle(_ height: CGFloat) -> CustomTextFieldStyle {
        CustomTextFieldStyle(height)
    }
}

//
//  CustomCapsuleModifier.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct CustomCapsuleModifier: ViewModifier {
    let input: Bool
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .frame(height: 50)
            .font(.system(size: 17, weight: input ? .regular : .medium))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(input ? .white : .dirtyWhite.opacity(0.1), lineWidth: 1)
            }
    }
}

extension View {
    func customCapsule(_ input: Bool = false) -> some View {
        modifier(CustomCapsuleModifier(input: input))
    }
}

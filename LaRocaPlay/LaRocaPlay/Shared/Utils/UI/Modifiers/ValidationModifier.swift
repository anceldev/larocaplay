//
//  ValidationModifier.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 8/1/26.
//

import SwiftUI

struct ValidationModifier: ViewModifier {
    
    let errorMessage: String?
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)       // Smaller text for error message
                    .foregroundColor(.red)
                    .frame(height: 20)    // Keep consistent height
//                    .opacity(errorMessage == nil ? 0 : 1)  // Hide when no error
                    .animation(.easeInOut(duration: 0.2), value: errorMessage) // Smooth transition
            }
        }
    }
}

extension View {
    func withValidation(_ errorMessage: String?) -> some View {
        self.modifier(ValidationModifier(errorMessage: errorMessage))
    }
}

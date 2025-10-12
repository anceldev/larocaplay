//
//  ValidatorViewModifier.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI

struct ValidatorViewModifier: ViewModifier {
    let value: String
     let field: String
     let shouldValidate: Bool
     @Binding var validationResults: [String: Bool]
     let validationRule: (String) -> String?
     
     @State private var errorMessage: String?
     
     func body(content: Content) -> some View {
         VStack(alignment: .leading, spacing: 4) {
             content
                 .onChange(of: value, validate)
                 .onChange(of: shouldValidate, validate)
             
             if let errorMessage {
                 Text(errorMessage)
                     .foregroundStyle(.red)
                     .font(.caption)
             }
         }
     }
     
     private func validate() {
         errorMessage = validationRule(value)
         validationResults[field] = (errorMessage == nil)
     }
 }



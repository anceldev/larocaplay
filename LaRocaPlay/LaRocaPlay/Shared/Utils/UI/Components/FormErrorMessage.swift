//
//  FormErrorMessage.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/1/26.
//

import SwiftUI

struct FormErrorMessage: View {
    let errorMessage: String
    var body: some View {
        Text(errorMessage)
            .foregroundStyle(.red)
            .font(.system(size: 14))
            .padding(.horizontal, 24)
            .multilineTextAlignment(.center)
    }
}

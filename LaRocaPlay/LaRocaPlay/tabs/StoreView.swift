//
//  StoreView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI

struct StoreView: View {
    var body: some View {
        Text("StoreView")
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    StoreView()
}

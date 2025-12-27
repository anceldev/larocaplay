//
//  RootView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import SwiftData
import SwiftUI

struct RootView: View {
    var body: some View {
        MainScreen()
            .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

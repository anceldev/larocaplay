//
//  RootView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(LibraryManager.self) private var libManager
    @Environment(AuthManager.self) private var authManager
    var body: some View {
        MainScreen()
            .enableInjection()
            .task {
                await libManager.initialSync()
            }
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

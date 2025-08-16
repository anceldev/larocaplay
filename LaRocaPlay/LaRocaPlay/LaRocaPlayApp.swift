//
//  LaRocaPlayApp.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI

@main
struct LaRocaPlayApp: App {
    @State private var service = AWService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(service)
    }
}

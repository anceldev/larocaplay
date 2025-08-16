//
//  PreachesView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI
import AVKit

struct PreachesView: View {
//    @Environment(AWService.self) var awService
//    @State var error: Error?
//    @State var preaches: [Preach] = []
//    @State private var player = AVPlayer(url: URL(string: "https://player.vimeo.com/video/1105734458")!)
//    
//    private func loadPreaches() {
//        Task {
//            do {
//                self.preaches = try await awService.getPreaches()
//            } catch {
//                self.error = error
//            }
//        }
//    }
    
    var body: some View {
        Text("Preaches view")
//        NavigationStack {
//            VStack {
//                Text("PreachesView")
//                ScrollView(.vertical) {
//                    ForEach(preaches) { preach in
//                        NavigationLink(value: preach) {
//                            VStack {
//                                AsyncImage(url: preach.thumb)
//                                    .aspectRatio(16/9, contentMode: .fit)
//                                Text(preach.title)
//                                Text(preach.preacher)
//                            }
//                        }
//                    }
//                }
//                .navigationDestination(for: Preach.self) { 
//                    PreachScreen(preach: $0)
//                }
//            }
//            .onAppear {
//                loadPreaches()
//            }
//        }
    }
}

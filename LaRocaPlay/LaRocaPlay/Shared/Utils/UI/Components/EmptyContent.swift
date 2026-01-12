//
//  EmptyContent.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/1/26.
//

import SwiftUI

struct EmptyContent<Content: View>: View {

    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}


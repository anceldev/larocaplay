//
//  AboutUsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 10/1/26.
//

import SwiftUI

struct AboutUsScreen: View {
    var body: some View {
        VStack {
            Text("AboutUsScreen")
        }
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

#Preview {
    AboutUsScreen()
}

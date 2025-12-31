//
//  TopBarScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 7/12/25.
//

import SwiftUI

struct TopBarScreen: View {
    @Environment(AppRouter.self) var router
    let title: String
    let backButton: Bool
//    let storageCollection: StorageCollections
    
    init(title: String, _ backButton: Bool = false) {
        self.title = title.truncated()
        self.backButton = backButton
    }

    var body: some View {
        ZStack {
            HStack {
                if backButton {
                    Button {
                        router.popNavigation()
                    } label: {
                        Circle()
                            .tint(.customGray)
                            .frame(width: 32)
                            .overlay(alignment: .center) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.customBlack)
                            }
                    }
                }
                Spacer()
            }
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

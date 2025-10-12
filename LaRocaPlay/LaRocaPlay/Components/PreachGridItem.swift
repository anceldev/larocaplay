//
//  PreachGridItem.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI

struct PreachGridItem: View {
    let preach: Preach
    
    init(_ preach: Preach) {
        self.preach = preach
    }
    var body: some View {
        VStack(spacing: 8) {
//            VStack {
//                Color.gray
                Image(.thumbPreview)
                    .resizable()
//                    .scaledToFit()
//            }
            .aspectRatio(4/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 4) {
                Text(preach.title)
//                    .foregroundStyle(.customBlack)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading) {
                    if let preacher = preach.preacher {
                        HStack(spacing: 4) {
                            Text(preacher.role ?? "")
                            Text(preacher.name)
                        }
                        .font(.system(size: 12, weight: .semibold))
//                        .foregroundStyle(.customBlack.opacity(0.8))
                        .foregroundStyle(.dirtyWhite)
                    }
                    Text(preach.date, style: .date)
                        .font(.system(size: 10))
//                        .foregroundStyle(.customBlack.opacity(0.7))
                        .foregroundStyle(.dirtyWhite)
                }
                    
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

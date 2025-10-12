//
//  PreachView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import Foundation
import SwiftUI

struct PreachView: View {
    
    @Environment(AppRouter.self) var router
    var preach: Preach
    
    let spanishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE d 'de' MMMM 'de' y"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                
                
                VStack {
                    VimeoEmbedPlayer(videoURL: preach.video)
                        .aspectRatio(16/9, contentMode: .fit)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .customBlack.opacity(0.5), radius: 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        VStack(alignment: .leading) {
                            Text(preach.title)
                                .font(.system(size: 24))
                            if let preacher = preach.preacher {
                                Button {
                                    router.navigateTo(.preacher(preacher: preacher))
                                } label: {
                                    
                                    HStack(spacing: 4) {
                                        Text(preacher.role ?? "")
                                        Text(preacher.name)
                                            .underline(true, color: .customBlack.opacity(0.5))
                                    }
                                    .foregroundStyle(.customBlack.opacity(0.8))
                                    .font(.system(size: 16))
                                }
                            }
                        }
                        Text(spanishDateFormatter.string(from: preach.date))
                            .font(.system(size: 14))
                    }
                    if let description = preach.description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

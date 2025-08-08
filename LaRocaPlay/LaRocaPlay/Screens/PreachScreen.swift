//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI

struct PreachScreen: View {
    var preach: Preach
    var body: some View {
        VStack {
            VStack {
                VimeoPlayerView(url: preach.video)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(16/9, contentMode: .fit)
            VStack {
                HStack {
                    Text(preach.title)
                    if let serie = preach.serie {
                        Text(serie)
                    }
                }
                Text(preach.preacher)
                Text(preach.date, style: .date)
            }
            Spacer()
        }
    }
}

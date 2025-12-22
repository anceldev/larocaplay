//
//  PreachGridItem.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI


struct PreachGridItem: View {
    let preach: Preach
    let listView: ListView
    let aspect: CGFloat
    
    init(_ preach: Preach, listView: ListView = .single, aspect: CGFloat = 16/9, titleAlignment: TextAlignment = .leading) {
        self.preach = preach
        self.listView = listView
        self.aspect = aspect
    }
    var body: some View {
        VStack {
            switch listView {
            case .single:
                VStack(spacing: 8) {
                    ThumbImageLoader(storageCollection: .preaches(preach.thumbId))
                    VStack(alignment: .center, spacing: 4) {
                        Text(preach.title)
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .multilineTextAlignment(.center)
                        HStack(alignment: .center , spacing: 4) {
                            HStack(alignment: .top, spacing: 4) {
                                Text(preach.preacher.role.name)
                                Text(preach.preacher.name)
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.dirtyWhite)
                            Text("- \(preach.date, style: .date)")
                                .font(.system(size: 10))
                                .foregroundStyle(.dirtyWhite)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            case .grid:
                VStack(spacing: 8) {
                    ThumbImageLoader(storageCollection: .preaches(preach.thumbId))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preach.title)
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .multilineTextAlignment(.leading)
//                        HStack(alignment: .center , spacing: 8) {
//                            HStack(spacing: 4) {
//                                Text(preach.preacher.role.name)
//                                Text(preach.preacher.name)
//                            }
//                            .font(.system(size: 10, weight: .semibold))
//                            .foregroundStyle(.dirtyWhite)
//                            Text(preach.date, style: .date)
//                                .font(.system(size: 10))
//                                .foregroundStyle(.dirtyWhite)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(alignment: .center , spacing: 8) {
                            HStack(spacing: 4) {
                                Text("\(preach.preacher.role.name) \(preach.preacher.name) - \(Text(preach.date, style: .date))")
//                                Text(preach.preacher.name)
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.dirtyWhite)
//                            Text(preach.date, style: .date)
//                                .font(.system(size: 10))
//                                .foregroundStyle(.dirtyWhite)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            case .list:
                VStack {
                    HStack(spacing: 8) {
                        ThumbImageLoader(storageCollection: .preaches(preach.thumbId))
                        VStack(alignment: .leading, spacing: 8) {
                            Text(preach.title)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .multilineTextAlignment(.leading)
                            HStack(alignment: .center , spacing: 8) {
                                HStack(spacing: 4) {
                                    Text(preach.preacher.role.name)
                                    Text(preach.preacher.name)
                                }
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.dirtyWhite)
                                Text(preach.date, style: .date)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.dirtyWhite)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                    .padding(.vertical, 6)
                }
                .enableInjection()
            }
        }
    }
#if DEBUG
            @ObserveInjection var forceRedraw
#endif
}

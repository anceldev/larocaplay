//
//  ListViewButton.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 14/12/25.
//

import SwiftUI

struct ListViewButton: View {
    @Binding var listView: ListView
    var buttonImage: ImageResource {
        switch self.listView {
        case .single:
            return .presentationScreen
        case .grid:
            return .gridCirclePlus
        case .list:
            return .unorderedList
        }
    }
    var body: some View {
        VStack {
            Menu {
                Button {
                    withAnimation(.easeInOut) {
                        listView = .single
                    }
                } label: {
                    HStack {
                        Image(.presentationScreen)
                            .foregroundStyle(.dirtyWhite)
                        Text("Individual")
                        Spacer()
                        if listView == .single {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundStyle(listView == .single ? .customRed : .dirtyWhite)
                
                Button {
                    withAnimation(.easeInOut) {
                        listView = .grid
                    }
                } label: {
                    HStack {
                        Image(.gridCirclePlus)
                            .foregroundStyle(listView == .grid ? .customRed : .dirtyWhite)
                        Text("Grid")
                        Spacer()
                        if listView == .grid {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundStyle(listView == .grid ? .customRed : .dirtyWhite)
                Button {
                    withAnimation(.easeInOut) {
                        listView = .list
                    }
                } label: {
                    HStack {
                        Image(.unorderedList)
                            .foregroundStyle(listView == .list ? .customRed : .dirtyWhite)
                        Text("Lista")
                        Spacer()
                    }
                    .foregroundStyle(listView == .list ? .customRed : .dirtyWhite)
                }
            } label: {
                VStack {
                    Image(buttonImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .foregroundStyle(.dirtyWhite)
                }
                .padding(8)
                .clipShape(.circle)
                .overlay {
                    Circle().stroke(.dirtyWhite, lineWidth: 1)
                }
            }
        }
        .padding(.trailing, 8)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}



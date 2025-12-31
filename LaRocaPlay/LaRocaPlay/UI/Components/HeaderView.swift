//
//  HeaderView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/12/25.
//

import SwiftUI

struct HeaderView: View {
    @Environment(AppRouter.self) var router
    @State private var errorMessage: String? = nil
    @State private var image: UIImage? = nil
    
    let storageCollection: StorageCollections
    
    var body: some View {
        VStack {
//            VStack(alignment: .leading) {
//                Button {
//                    router.popNavigation()
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                            .foregroundStyle(.customRed)
//                    }
//                }
//            }
//            .padding(.top, 16)
//            .padding(.leading, 16)
            //            ThumbImageLoader(storageCollection: storageCollection)
            ZStack {
                Color.gray
                    .aspectRatio(16/9, contentMode: .fit)
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                    //                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity)
//            .background(RoundedRectangle(cornerRadius: 20))
            .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
            .aspectRatio(16/9, contentMode: .fit)
            .onAppear {
                loadImage()
            }
            
        }
        
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func loadImage() {
        Task {
            do {
                self.errorMessage = nil
                guard self.image == nil else {
                    return
                }
                self.image = try await ImageCacheManager.shared.getThumbnail(path: storageCollection)
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

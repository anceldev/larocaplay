//
//  ThumbImageLoader.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 7/12/25.
//

import SwiftUI

struct ThumbImageLoader: View {
    
    @State private var errorMessage: String? = nil
    @State private var image: UIImage? = nil
    var cornerRadius: CGFloat
    
    var title: String?
    var storageCollection: StorageCollections
    
    init(title: String? = nil, storageCollection: StorageCollections, cornerRadius: CGFloat = 20) {
        self.title = title
        self.storageCollection = storageCollection
        self.cornerRadius = cornerRadius
    }
    
    
    var body: some View {
        ZStack {
            Color.gray
                .aspectRatio(16/9, contentMode: .fit)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            if let title {
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .shadow(color: .black, radius: 6, x: 1, y: 1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .foregroundStyle(.white)
            }
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear {
            loadImage()
        }
        .enableInjection()
    }
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
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

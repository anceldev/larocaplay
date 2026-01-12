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
    var aspect: CGFloat
    let radius: CGFloat
    
    init(
        title: String? = nil, storageCollection: StorageCollections, cornerRadius: CGFloat = 20,
        aspect: CGFloat = 16/9,
        radius: CGFloat = Theme.Radius.player
    ) {
        self.title = title
        self.storageCollection = storageCollection
        self.cornerRadius = cornerRadius
        self.aspect = aspect
        self.radius = radius
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .aspectRatio(aspect, contentMode: .fit)
            if let image {
                if #available(iOS 26.0, *) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)
                        .glassEffect(in: RoundedRectangle(cornerRadius: radius))
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)
                }
            }
            if let title, self.image == nil {
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
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .aspectRatio(aspect, contentMode: .fit)
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

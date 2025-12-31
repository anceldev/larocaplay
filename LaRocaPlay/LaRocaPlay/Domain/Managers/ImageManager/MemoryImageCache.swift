//
//  MemoryImageCache.swift
//  Movix
//
//  Created by Ancel Dev account on 7/2/25.
//

import Foundation
import SwiftUI

actor MemoryImageCache: ImageCacheProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 200 // 200MB
    }
    
    func getImage(forKey key: String) async throws -> UIImage? {
        guard !key.isEmpty else {
            throw ImageCacheError.loadFailed("Empty key")
        }
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) async throws {
        guard !key.isEmpty else {
            throw ImageCacheError.saveFailed("Empty key")
        }
        cache.setObject(image, forKey: key as NSString)
    }
    
    func removeImage(forKey key: String) async throws {
        guard !key.isEmpty else {
            throw ImageCacheError.deleteFailed("Empty key")
        }
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearCache() async throws {
        cache.removeAllObjects()
    }
}

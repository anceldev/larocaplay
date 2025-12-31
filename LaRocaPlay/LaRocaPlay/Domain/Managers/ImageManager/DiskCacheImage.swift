//
//  DiskCacheImage.swift
//  Movix
//
//  Created by Ancel Dev account on 7/2/25.
//

import Foundation
import SwiftUI

actor DiskCacheImage: ImageCacheProtocol {
    private let filemanager = FileManager.default
    private let cacheDirectory: URL
    
    private nonisolated let cachePath: String
    
    init() throws {
        guard let documentsDirectory = try? filemanager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            throw ImageCacheError.cacheDirectoryNotFound
        }
        self.cacheDirectory = documentsDirectory.appending(path: "ImageCache")
        self.cachePath = cacheDirectory.path()
        
        if !filemanager.fileExists(atPath: cachePath) {
            do {
                try filemanager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                throw ImageCacheError.directoryCreationFailed
            }
        }
    }
    
    private func fileURL(forKey key: String) throws -> URL {
        guard !key.isEmpty else {
            throw ImageCacheError.invalidFileURL
        }
        let sanitizedKey = key.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "\\", with: "_")
        return cacheDirectory.appendingPathComponent(sanitizedKey)
    }
    
    func getImage(forKey key: String) async throws -> UIImage? {
        let fileURL = try fileURL(forKey: key)
        
        do {
            let data = try Data(contentsOf: fileURL)
            guard let image = UIImage(data: data) else {
                throw ImageCacheError.invalidImage
            }
            return image
        } catch let error as ImageCacheError {
            throw error
        } catch {
            throw ImageCacheError.loadFailed(error.localizedDescription)
        }
    }
    
    func saveImage(_ image: UIImage, forKey key: String) async throws {
        let fileURL = try fileURL(forKey: key)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageCacheError.compressionFailed
        }
        do {
            try data.write(to: fileURL)
        } catch {
            throw ImageCacheError.saveFailed(error.localizedDescription)
        }
    }
    
    func removeImage(forKey key: String) async throws {
        let fileURL = try fileURL(forKey: key)
        
        do {
            try filemanager.removeItem(at: fileURL)
        } catch {
            throw ImageCacheError.deleteFailed(error.localizedDescription)
        }
    }
    
    func clearCache() async throws {
        do {
            try filemanager.removeItem(at: cacheDirectory)
            try filemanager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            throw ImageCacheError.deleteFailed(error.localizedDescription)
        }
    }
}

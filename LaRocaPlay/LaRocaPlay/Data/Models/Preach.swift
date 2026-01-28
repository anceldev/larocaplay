//
//  Preach.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import SwiftData

@Model
final class Preach {
    @Attribute(.unique) var id: Int
    var title: String
    var desc: String?
    var date: Date
    var videoId: String
    var imageId: String?
    var updatedAt: Date
    
    var videoUrl: String?
    var videoUrlExpiration: Date?
    var preacher: Preacher?

    @Relationship(deleteRule: .cascade, inverse: \CollectionItem.preach) var collectionLinks: [CollectionItem] = []
    
    var hasValidUrl: Bool {
        guard let expiration = videoUrlExpiration,
              let url = videoUrl,
              !url.isEmpty
        else { return false }
        let safetyMargin: TimeInterval = 2 * 3600
        return expiration > Date().addingTimeInterval(safetyMargin)
    }
    
    init(id: Int, title: String, desc: String? = nil, date: Date, videoId: String, imageId: String? = nil, preacher: Preacher? = nil, updatedAt: Date) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
        self.videoId = videoId
        self.imageId = imageId
        self.preacher = preacher
        self.updatedAt = updatedAt
    }
    
    func update(from dto: PreachDTO) {
        self.title = dto.title
        self.desc = dto.description
        self.date = dto.date
        self.videoId = dto.videoId
        self.imageId = dto.imageId
        self.updatedAt = dto.updatedAt
    }
    
    func updateVideoCache(url: String, expiration: Date) {
        self.videoUrl = url
        self.videoUrlExpiration = expiration
    }
}

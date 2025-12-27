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
    var updatedAt: Date?
    
    var preacher: Preacher?
//    var collections: [Collection] = []
    @Relationship(deleteRule: .cascade, inverse: \CollectionItem.preach) var collectionLinks: [CollectionItem] = []
    
    
    init(id: Int, title: String, desc: String? = nil, date: Date, videoId: String, imageId: String? = nil, preacher: Preacher? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
        self.videoId = videoId
        self.imageId = imageId
        self.preacher = preacher
//        self.collections = collections
    }
    
    func update(from dto: PreachDTO) {
        self.title = dto.title
        self.desc = dto.description
        self.date = dto.date
        self.videoId = dto.videoUrl
        self.imageId = dto.thumbId
        self.updatedAt = dto.updatedAt
    }
}

//
//  Song.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import Foundation
import SwiftData

@Model
final class Song {
    @Attribute(.unique) var id: Int
    var title: String
    var videoId: String
    var updatedAt: Date
    
    init(id: Int, title: String, videoId: String, updatedAt: Date) {
        self.id = id
        self.title = title
        self.videoId = videoId
        self.updatedAt = updatedAt
    }
    
    func update(from: SongDTO) {
        self.title = title
        self.videoId = videoId
        self.updatedAt = updatedAt
    }
}

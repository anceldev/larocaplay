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
    
    init(id: Int, title: String, videoId: String) {
        self.id = id
        self.title = title
        self.videoId = videoId
    }
}

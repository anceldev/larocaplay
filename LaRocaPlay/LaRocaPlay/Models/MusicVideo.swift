//
//  MusicVideo.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 4/12/25.
//

import Foundation

struct MusicVideo: Codable, Identifiable {
    var id: Int
    var createdAt: Date
    var songName: String
    var videoUrl: String
    var thumbId: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case songName = "song_name"
        case videoUrl = "video_url"
        case thumbId = "thumb_id"
    }
}

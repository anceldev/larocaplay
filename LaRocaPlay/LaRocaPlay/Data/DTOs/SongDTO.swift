//
//  SongDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import Foundation

struct SongDTO: Codable {
    var id: Int
    var title: String
    var videoId: String
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case videoId = "video_id"
    }
    
    func toModel() -> Song {
        return .init(
            id: self.id,
            title: self.title,
            videoId: self.videoId
        )
    }
}

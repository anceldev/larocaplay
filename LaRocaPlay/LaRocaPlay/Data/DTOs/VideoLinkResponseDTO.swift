//
//  VimeoVideoCache.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 22/12/25.
//

import Foundation

struct VideoLinkResponseDTO: Codable {
    var videoId: String
    var videoUrl: String
    var linkExpirationTime: Date
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case videoUrl = "video_url"
        case linkExpirationTime = "link_expiration_time"
    }
    
    init(videoId: String, videoUrl: String, linkExpirationTime: Date) {
        self.videoId = videoId
        self.videoUrl = videoUrl
        self.linkExpirationTime = linkExpirationTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
//        self.linkExpirationTime = try container.decode(Date.self, forKey: .linkExpirationTime)
        let expirationString = try container.decode(String.self, forKey: .linkExpirationTime)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = formatter.date(from: expirationString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .linkExpirationTime,
                in: container,
                debugDescription: "Invalid date format: \(expirationString)"
            )
        }
        self.linkExpirationTime = date
    }
}

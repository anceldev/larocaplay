//
//  VimeoResponse.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/12/25.
//

import Foundation

struct SupabaseVideo: Codable {
//    let id: Int
    let videoId: String
    let link: String
    let linkExpirationTime: Date
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case link
        case linkExpirationTime = "link_expiration_time"
    }
}

struct VimeoResponse: Decodable {
    let name: String
    let duration: Int
    let files: [FileDetails]
    let play: VimeoVideoPlay
    
    enum CodingKeys: CodingKey {
        case name
        case duration
        case files
        case play
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.files = try container.decode([FileDetails].self, forKey: .files)
        self.play = try container.decode(VimeoVideoPlay.self, forKey: .play)
    }
}

struct VimeoVideoPlay: Decodable {
    let progressive: [VimeoVideoPlayProgressive]
}

struct VimeoVideoPlayProgressive: Decodable {
    let link: String
    let linkExpirationTime: Date
    let rendition: String
    
    enum CodingKeys: String, CodingKey {
        case link, rendition
        case linkExpirationTime = "link_expiration_time"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.link = try container.decode(String.self, forKey: .link)
        self.rendition = try container.decode(String.self, forKey: .rendition)
        self.linkExpirationTime = try container.decode(Date.self, forKey: .linkExpirationTime)
    }
}

struct FileDetails: Decodable {
    let link: String?
    let type: String?
    let quality: String?
    
    var isHLS: Bool {
        return type == "hls"
    }
    
    enum CodingKeys: CodingKey {
        case link
        case type
        case quality
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.link = try container.decodeIfPresent(String.self, forKey: .link)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.quality = try container.decodeIfPresent(String.self, forKey: .quality)
    }
}

struct VimeoVideoResponse: Codable {
    let videoId: String
    let link: String
    let linkExpirationTime: Date
    
    enum CodingKeys: String, CodingKey {
        case link
        case videoId = "video_id"
        case linkExpirationTime = "link_expiration_time"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.link = try container.decode(String.self, forKey: .link)
        self.videoId = try container.decode(String.self, forKey: .videoId)
//        self.linkExpirationTime = try container.decode(Date.self, forKey: .linkExpirationTime)
        let dateString = try container.decode(String.self, forKey: .linkExpirationTime)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .linkExpirationTime,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        self.linkExpirationTime = date
    }
}

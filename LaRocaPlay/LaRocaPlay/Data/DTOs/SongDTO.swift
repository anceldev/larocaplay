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
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case videoId = "video_id"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        let updateString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let updatedDate = formatter.date(from: updateString) {
            self.updatedAt = updatedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let updatedDate = formatter.date(from: updateString) else {
                throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Fecha inválida")
            }
            self.updatedAt = updatedDate
        }
    }
    
    func toModel() -> Song {
        return .init(
            id: self.id,
            title: self.title,
            videoId: self.videoId,
            updatedAt: self.updatedAt
        )
    }
}

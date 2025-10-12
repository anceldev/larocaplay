//
//  MusicItem.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import Foundation

struct MusicItem: Decodable, Identifiable {
    let id: Int
    let createdAt: Date
    let name: String
    let description: String?
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, url
        case createdAt = "created_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decode(URL.self, forKey: .url)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

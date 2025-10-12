//
//  Serie.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

import Foundation

struct Serie: Codable, Identifiable, Hashable {
    let id: Int
    let createdAt: Date
    let name: String
    let description: String?
    let thumbId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case createdAt = "created_at"
        case thumbId = "thumb_id"
    }
    
    init(id: Int, createdAt: Date = .now, name: String, description: String? = nil, thumbId: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.description = description
        self.thumbId = thumbId
    }
   
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
//        decoder.dateDecodingStrategy = .iso8601
        
//        let createAtString = try container.decode(String.self, forKey: .createdAt)
//        print(createAtString)
//        self.createdAt = .now
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//        if let createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            self.createdAt = dateFormatter.date(from: createdAt) ?? .now
//        } else {
//            self.createdAt = .now
//        }
//        
//
//
//        guard let createdAt = DateFormatter.supabaseTimestamp.date(from: createdAtString) else {
//            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Wrong timestampz format")
//        }
//        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//        self.createdAt = createdAt
        
        self.thumbId = try container.decodeIfPresent(String.self, forKey: .thumbId)
    }
}

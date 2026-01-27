//
//  CollectionItemResponseDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import Foundation
import SwiftData

struct ShortCollectionItemResponseDTO: Decodable {
    var id: Int
    var preach: ShortPreachDTO
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, preach
        case updatedAt = "updated_at"
    }
    
}

struct CollectionItemResponseDTO: Decodable {
    let id: Int
    let preach: PreachDTO
    let position: Int?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, preach, position
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.preach = try container.decode(PreachDTO.self, forKey: .preach)
        self.position = try container.decodeIfPresent(Int.self, forKey: .position)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//        let createdString = try container.decode(String.self, forKey: .createdAt)
//        guard let decodedCreatedDate = DateFormatter.decodedSupabaseDate(createdString)else {
//            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "wrong created_at format")
//        }
//        self.createdAt = decodedCreatedDate
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    
    func toModel() -> CollectionItem {
        CollectionItem(
            id: id,
            position: position ?? 0,
            preach: preach.toModel(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct CollectionItemFromNotification: Decodable {
    let preachId: Int
    let collectionId: Int
}

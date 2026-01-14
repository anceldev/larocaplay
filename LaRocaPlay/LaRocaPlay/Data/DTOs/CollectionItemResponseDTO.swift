//
//  CollectionItemResponseDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import Foundation
import SwiftData

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

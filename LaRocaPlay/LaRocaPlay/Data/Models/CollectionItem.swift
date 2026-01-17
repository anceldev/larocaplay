//
//  CollectionItem.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import SwiftData

@Model
final class CollectionItem {
    @Attribute(.unique) var id: Int
    var position: Int
    var collection: Collection?
    var preach: Preach?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, position: Int, collection: Collection? = nil, preach: Preach? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.position = position
        self.collection = collection
        self.preach = preach
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func update(from dto: CollectionItemResponseDTO) {
        self.position = dto.position ?? 0
//        self.preach = from.preach.toModel()
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        guard let existingPreach = self.preach,
              dto.preach.updatedAt > existingPreach.updatedAt else { return }
        existingPreach.update(from: dto.preach)
    }
}

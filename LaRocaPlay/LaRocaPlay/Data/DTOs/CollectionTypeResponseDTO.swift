////
////  PreachCollection.swift
////  LaRocaPlay
////
////  Created by Ancel Dev account on 19/8/25.
////

import Foundation

struct CollectionTypeResponseDTO: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    
    func toModel() -> CollectionType {
        let model = CollectionType(
            id: self.id,
            name: self.name
        )
        return model
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

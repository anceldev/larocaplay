//
//  CollectionDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation



struct CollectionDTO: Codable, Identifiable, Hashable {
    var id: Int
    var title: String
    var description: String?
    var imageId: String?
    var collectionType: CollectionTypeResponseDTO
    var isPublic: Bool
    var isHomeScreen: Bool
    var createdAt: Date
    var updatedAt: Date
    var endedAt: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case imageId = "image_id"
        case isPublic = "is_public"
        case isHomeScreen = "is_home_screen"
        case collectionType = "collection_type_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case endedAt = "ended_at"
    }
    
    init(id: Int, title: String, description: String? = nil, thumbId: String? = nil, isPublic: Bool, isHomeScreen: Bool = false, collectionType: CollectionTypeResponseDTO, createdAt: Date = .now, updatedAt: Date = .now, endedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imageId = thumbId
        self.isPublic = isPublic
        self.isHomeScreen = isHomeScreen
        self.collectionType = collectionType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.endedAt = endedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
        self.isHomeScreen = try container.decode(Bool.self, forKey: .isHomeScreen)
        self.collectionType = try container.decode(CollectionTypeResponseDTO.self, forKey: .collectionType)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.endedAt = try container.decodeIfPresent(Date.self, forKey: .endedAt)
    }
    
    func toModel() -> Collection {
        let model = Collection(
            id: self.id,
            title: self.title,
            desc: self.description,
            imageId: self.imageId,
            isPublic: self.isPublic,
            isHomeScreen: self.isHomeScreen,
            typeName: self.collectionType.name,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            endedAt: self.endedAt,
        )
        return model
    }
}

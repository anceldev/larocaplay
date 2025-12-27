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
    var thumbId: String?
    var collectionType: PreachCollectionType
    var isPublic: Bool
    var isHomeScreen: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var endedAt: Date?
    var preaches: [PreachDTO]
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case thumbId = "thumb_id"
        case isPublic = "is_public"
        case isHomeScreen = "is_home_screen"
        case collectionType = "collection_type_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case endedAt = "ended_at"
    }
    
    init(id: Int, title: String, description: String? = nil, thumbId: String? = nil, isPublic: Bool, isHomeScreen: Bool = false, collectionType: PreachCollectionType, createdAt: Date? = nil, updatedAt: Date? = nil, endedAt: Date? = nil, preaches: [PreachDTO] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.thumbId = thumbId
        self.isPublic = isPublic
        self.isHomeScreen = isHomeScreen
        self.collectionType = collectionType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.endedAt = endedAt
        self.preaches = preaches
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.thumbId = try container.decodeIfPresent(String.self, forKey: .thumbId)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
        self.isHomeScreen = try container.decode(Bool.self, forKey: .isHomeScreen)
        self.collectionType = try container.decode(PreachCollectionType.self, forKey: .collectionType)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.endedAt = try container.decodeIfPresent(Date.self, forKey: .endedAt)
        self.preaches = []
    }
    
    func toModel() -> Collection {
        let model = Collection(
            id: self.id,
            title: self.title,
            desc: self.description,
            imageId: self.thumbId,
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
//
//struct PreachCollectionType: Identifiable, Codable, Hashable {
//    let id: Int
//    let name: String
//}
//
//struct PreachCollectionWrapper: Decodable {
//    let preach: Preach
//}

//
//  Collection.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import SwiftData

@Model
final class Collection {
    @Attribute(.unique) var id: Int
    var title: String
    var desc: String?
    var imageId: String?
    var isPublic: Bool
    var isHomeScreen: Bool
    // TODO: Añadir ColectionType. solo como texto o con el id?? pregunta a IA
    var createdAt: Date?
    var updatedAt: Date?
    var endedAt: Date?
    
    @Relationship(inverse: \Preach.collections) var preaches: [Preach]?
    
    init(id: Int, title: String, desc: String? = nil, imageId: String? = nil, isPublic: Bool, isHomeScreen: Bool, createdAt: Date? = nil, updatedAt: Date? = nil, endedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.imageId = imageId
        self.isPublic = isPublic
        self.isHomeScreen = isHomeScreen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.endedAt = endedAt
    }
}

@Model
final class CollectionType {
    @Attribute(.unique) var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

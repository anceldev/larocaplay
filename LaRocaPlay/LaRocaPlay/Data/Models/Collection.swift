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
    var typeName: String
    var createdAt: Date?
    var updatedAt: Date?
    var endedAt: Date?
    
//    @Relationship(inverse: \Preach.collections) var preaches: [Preach] = []
    @Relationship(deleteRule: .cascade, inverse: \CollectionItem.collection) var items: [CollectionItem] = []

    
    init(id: Int, title: String, desc: String? = nil, imageId: String? = nil, isPublic: Bool, isHomeScreen: Bool, typeName: String, createdAt: Date? = nil, updatedAt: Date? = nil, endedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.imageId = imageId
        self.isPublic = isPublic
        self.isHomeScreen = isHomeScreen
        self.typeName = typeName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.endedAt = endedAt
    }
}

extension Collection {
    var pagedPreaches: [Preach] {
        items.sorted{ $0.position < $1.position }.compactMap { $0.preach }
    }
    var latestPreaches: [Preach] {
        items.compactMap { $0.preach }.sorted { $0.date > $1.date }
    }
}


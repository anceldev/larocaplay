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
    var createdAt: Date
    var updatedAt: Date
    var endedAt: Date?
    var needItemsSync: Bool = true
    
//    @Relationship(inverse: \Preach.collections) var preaches: [Preach] = []
    @Relationship(deleteRule: .cascade, inverse: \CollectionItem.collection) var items: [CollectionItem] = []

    
    init(id: Int, title: String, desc: String? = nil, imageId: String? = nil, isPublic: Bool, isHomeScreen: Bool, typeName: String, createdAt: Date, updatedAt: Date, endedAt: Date? = nil, needItemsSync: Bool = true) {
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
        self.needItemsSync = needItemsSync
    }
    func update(from dto: CollectionDTO) {
        self.title = dto.title
        self.desc = dto.description
        self.imageId = dto.imageId
        self.isPublic = dto.isPublic
        self.isHomeScreen = dto.isHomeScreen
        self.typeName = dto.collectionType.name
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.endedAt = dto.endedAt
    }
}

extension Collection {
    var pagedPreaches: [Preach] {
        items.sorted{ $0.position < $1.position }.compactMap { $0.preach }
    }
    var latestPreaches: [Preach] {
        items.compactMap { $0.preach }.sorted { $0.date > $1.date }
    }
    var itemsSortedByDate: [CollectionItem] {
        // Accedemos a los items y los ordenamos comparando la fecha de sus preaches
        return items.sorted { itemA, itemB in
            // Forzamos el desempaquetado ya que garantizas que siempre existe el preach
            return itemA.preach!.date > itemB.preach!.date
        }
    }
    var itemsSortedByPosition: [CollectionItem] {
        return items.sorted { $0.position < $1.position }
    }
}


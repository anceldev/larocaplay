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
    
    init(id: Int, position: Int, collection: Collection? = nil, preach: Preach? = nil) {
        self.id = id
        self.position = position
        self.collection = collection
        self.preach = preach
    }
}

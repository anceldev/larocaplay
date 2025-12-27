//
//  File.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import SwiftData

@Model
final class CollectionType {
    @Attribute(.unique) var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

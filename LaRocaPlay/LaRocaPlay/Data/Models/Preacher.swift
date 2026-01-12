//
//  PreacherDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

import Foundation
import SwiftData

@Model
final class Preacher {
    @Attribute(.unique) var id: Int
    var name: String
    var role: String?
    var photoId: String?
    var updatedAt: Date
    
    @Relationship(deleteRule: .noAction, inverse: \Preach.preacher) var preaches: [Preach] = []
    
    init(id: Int, name: String, role: String? = nil, photoId: String? = nil, updatedAt: Date) {
        self.id = id
        self.name = name
        self.role = role
        self.photoId = photoId
        self.updatedAt = updatedAt
    }
    
    func update(from: PreacherDTO) {
        self.id = from.id
        self.name = from.name
        self.role = from.role.name
        self.photoId = from.imageId
        self.updatedAt = from.updatedAt
    }
}




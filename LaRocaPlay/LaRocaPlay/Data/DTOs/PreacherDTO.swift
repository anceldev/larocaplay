//
//  PreacherDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

import Foundation

struct PreacherDTO: Codable, Identifiable, Equatable, Hashable {
    var id: Int
    var name: String
    var role: PreacherRole
    let imageId: String?
//    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case role = "preacher_role_id"
        case imageId = "imageId"
//        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.role = try container.decode(PreacherRole.self, forKey: .role)
        self.imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
        let updatedString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: updatedString) {
            self.updatedAt = date
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let updatedDate = formatter.date(from: updatedString) else {
                throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Fecha inválida")
            }
            self.updatedAt = updatedDate
        }
    }
    
    func toModel() -> Preacher {
        let model = Preacher(
            id: self.id,
            name: self.name,
            role: self.role.name,
            photoId: self.imageId,
            updatedAt: self.updatedAt
        )
        return model
    }
}


struct PreacherRole: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
}

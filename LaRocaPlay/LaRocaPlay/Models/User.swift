//
//  User.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/8/25.
//

import Foundation

struct User: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var email: String
//    var phone: String?
    var role: UserRole
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case email
        case role
    }
    init(id: UUID = UUID(), name: String, email: String, role: UserRole = .member ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.role = try container.decode(UserRole.self, forKey: .role)
    }
}

enum UserRole: String, Codable {
    case admin
    case pastor
    case supervisor
    case leader
    case member
}

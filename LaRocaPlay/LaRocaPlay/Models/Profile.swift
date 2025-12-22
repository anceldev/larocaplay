//
//  Profile.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 20/12/25.
//

import Foundation

struct Profile: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var displayName: String?
    var email: String
    var avatarUrl: String?
    var avatarId: String?
    var locale: String?
    var profileRole: ProfileRole
    
    enum CodingKeys: String, CodingKey {
        case email, locale
        case userId = "user_id"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case avatarId = "avatar_id"
        case profileRole = "profile_role"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .userId)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.locale = try container.decodeIfPresent(String.self, forKey: .locale)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.avatarId = try container.decodeIfPresent(String.self, forKey: .avatarId)
        self.profileRole = try container.decode(ProfileRole.self, forKey: .profileRole)
    }
}

enum ProfileRole: String, Codable {
    case admin
    case subscriptor
    case member
}



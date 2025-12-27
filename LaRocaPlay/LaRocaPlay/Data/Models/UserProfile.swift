//
//  UserProfile.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var userId: UUID
    var displayName: String?
    var email: String?
    var avatarURL: String?
    var avatarId: String?
    var locale: String?
    var profileRole: ProfileRole
    
    init(userId: UUID, displayName: String? = nil, email: String? = nil, avatarURL: String? = nil, avatarId: String? = nil, locale: String? = nil, profileRole: ProfileRole = .member) {
        self.userId = userId
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.avatarId = avatarId
        self.locale = locale
        self.profileRole = profileRole
    }
}

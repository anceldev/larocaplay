//
//  UserNotificationSettingsDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 23/1/26.
//

import Foundation


struct UserNotificationSettingsDTO: Codable {
    var userId: UUID
    var newMainCollectionItem: Bool
    var newPublicCollection: Bool
    var newPrivateCollection: Bool
    var newPublicCollectionItem: Bool
    var newPrivateCollectionItem: Bool
    var youtubeLive: Bool
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case newMainCollectionItem = "notify_main_collection"
        case newPublicCollection = "notify_new_public_collection"
        case newPrivateCollection = "notify_private_access"
        case newPublicCollectionItem = "notify_public_content"
        case newPrivateCollectionItem = "notify_private_content"
        case youtubeLive = "notify_youtube_live"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.newMainCollectionItem = try container.decode(Bool.self, forKey: .newMainCollectionItem)
        self.newPublicCollection = try container.decode(Bool.self, forKey: .newPublicCollection)
        self.newPrivateCollection = try container.decode(Bool.self, forKey: .newPrivateCollection)
        self.newPublicCollectionItem = try container.decode(Bool.self, forKey: .newPublicCollectionItem)
        self.newPrivateCollectionItem = try container.decode(Bool.self, forKey: .newPrivateCollectionItem)
        self.youtubeLive = try container.decode(Bool.self, forKey: .youtubeLive)
        let dateString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let updatedDate = formatter.date(from: dateString) {
            self.updatedAt = updatedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let updatedDate = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Fecha inválida")
            }
            self.updatedAt = updatedDate
        }
    }
    
    func toModel() -> UserNotificationSettings {
        .init(
            userId: self.userId,
            newMainCollectionItem: self.newMainCollectionItem,
            newPublicCollection: self.newPublicCollection,
            newPrivateCollection: self.newPrivateCollection,
            newPublicCollectionItem: self.newPublicCollection,
            newPrivateCollectionItem: self.newPrivateCollectionItem,
            youtubeLive: self.youtubeLive,
            updatedAt: self.updatedAt
        )
    }
}

extension UserNotificationSettingsDTO {
    init(from userNotificationSettings: UserNotificationSettings) {
        self.userId = userNotificationSettings.userId
        self.newMainCollectionItem = userNotificationSettings.newMainCollectionItem
        self.newPublicCollectionItem = userNotificationSettings.newPublicCollectionItem
        self.newPublicCollection = userNotificationSettings.newPublicCollection
        self.newPublicCollectionItem = userNotificationSettings.newPublicCollectionItem
        self.newPrivateCollection = userNotificationSettings.newPrivateCollection
        self.newPrivateCollectionItem = userNotificationSettings.newPrivateCollectionItem
        self.youtubeLive = userNotificationSettings.youtubeLive
        self.updatedAt = userNotificationSettings.updatedAt
    }
}

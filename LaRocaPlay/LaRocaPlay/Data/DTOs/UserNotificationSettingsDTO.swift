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
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case newMainCollectionItem = "notify_main_collection"
        case newPublicCollection = "notify_new_public_collection"
        case newPrivateCollection = "notify_private_access"
        case newPublicCollectionItem = "notify_public_content"
        case newPrivateCollectionItem = "notify_private_content"
        case youtubeLive = "notify_youtube_live"
    }
    
    func toModel() -> UserNotificationSettings {
        .init(
            userId: self.userId,
            newMainCollectionItem: self.newMainCollectionItem,
            newPublicCollection: self.newPublicCollection,
            newPrivateCollection: self.newPrivateCollection,
            newPublicCollectionItem: self.newPublicCollection,
            newPrivateCollectionItem: self.newPrivateCollectionItem,
            youtubeLive: self.youtubeLive
        )
    }
}

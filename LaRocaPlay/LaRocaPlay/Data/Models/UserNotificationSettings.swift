//
//  UserNotificationSettings.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 23/1/26.
//

import Foundation
import SwiftData

@Model
final class UserNotificationSettings {
    @Attribute(.unique) var userId: UUID
    var newMainCollectionItem: Bool
    var newPublicCollection: Bool
    var newPrivateCollection: Bool
    var newPublicCollectionItem: Bool
    var newPrivateCollectionItem: Bool
    var youtubeLive: Bool
    
    var user: UserProfile?
    
    init(
        userId: UUID,
        newMainCollectionItem: Bool = true,
        newPublicCollection: Bool = true,
        newPrivateCollection: Bool = true,
        newPublicCollectionItem: Bool = true,
        newPrivateCollectionItem: Bool = true,
        youtubeLive: Bool = true
    ) {
        self.userId = userId
        self.newMainCollectionItem = newMainCollectionItem
        self.newPublicCollection = newPublicCollection
        self.newPrivateCollection = newPrivateCollection
        self.newPublicCollectionItem = newPublicCollectionItem
        self.newPrivateCollectionItem = newPrivateCollectionItem
        self.youtubeLive = youtubeLive
    }
    
    func toDTO() -> UserNotificationSettingsDTO {
        .init(
            userId: self.userId,
            newMainCollectionItem: self.newMainCollectionItem,
            newPublicCollection: self.newPublicCollection,
            newPrivateCollection: self.newPrivateCollection,
            newPublicCollectionItem: self.newPublicCollectionItem,
            newPrivateCollectionItem: self.newPrivateCollectionItem,
            youtubeLive: self.youtubeLive
        )
    }
}

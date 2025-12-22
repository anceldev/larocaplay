//
//  Subscription.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 20/12/25.
//

import Foundation

struct Subscription: Codable, Identifiable {
    var id: Int
    var userId: UUID
    var rcAppUserId: String
    var entitlementId: String
    var productId: String
    var status: String
    var expiresAt: Date?
    var originalTransactionId: String?
    var lastEventAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case userId = "user_id"
        case rcAppUserId = "rc_app_user_id"
        case entitlementId = "entitlement_id"
        case productId = "product_id"
        case expiresAt = "expires_at"
        case originalTransactionId = "original_transaction_id"
        case lastEventAt = "last_event_at"
    }
}

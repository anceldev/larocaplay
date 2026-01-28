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

struct RCSubscription: Codable, Identifiable {
    var id: Int
    var userId: UUID
    var rcAppUserId: String
    var rcEntitlementId: String
    var rcProductId: String
    var rcProductDisplayName: String
    var rcStore: String
    var periodType: RCPeriodType
    var isActive: Bool
    var isSandbox: Bool
    var purchaseDate: Date
    var expiresDate: Date
    var priceAmount: Double?
    var priceCurrency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case rcAppUserId = "rc_app_user_id"
        case rcEntitlementId = "rc_entitlement_id"
        case rcProductId = "rc_product_id"
        case rcProductDisplayName = "rc_product_display_name"
        case rcStore = "rc_store"
        case periodType = "period_type"
        case isActive = "is_active"
        case isSandbox = "is_sandbox"
        case purchaseDate = "purchase_date"
        case expiresDate = "expires_date"
        case priceAmount = "price_amount"
        case priceCurrency = "price_currency"
    }
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        userId = try values.decode(UUID.self, forKey: .userId)
        rcAppUserId = try values.decode(String.self, forKey: .rcAppUserId)
        rcEntitlementId = try values.decode(String.self, forKey: .rcEntitlementId)
        rcProductId = try values.decode(String.self, forKey: .rcProductId)
        rcProductDisplayName = try values.decode(String.self, forKey: .rcProductDisplayName)
        rcStore = try values.decode(String.self, forKey: .rcStore)
        periodType = try values.decode(RCPeriodType.self, forKey: .periodType)
        isActive = try values.decode(Bool.self, forKey: .isActive)
        isSandbox = try values.decode(Bool.self, forKey: .isSandbox)
        purchaseDate = try values.decode(Date.self, forKey: .purchaseDate)
        expiresDate = try values.decode(Date.self, forKey: .expiresDate)
        priceAmount = try values.decodeIfPresent(Double.self, forKey: .priceAmount)
        priceCurrency = try values.decode(String.self, forKey: .priceCurrency)
    }
}

enum RCPeriodType: String, Codable{
    case normal
    case intro
    case trial
}

//
//  UserDeviceDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/1/26.
//

import Foundation

struct UserDeviceDTO: Codable {
    var deviceId: String
    var userId: UUID
    var fcmToken: String
    var deviceName: String?
    var deviceType: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case userId = "user_id"
        case fcmToken = "fcm_token"
        case deviceName = "device_name"
        case deviceType = "device_type"
    }
}

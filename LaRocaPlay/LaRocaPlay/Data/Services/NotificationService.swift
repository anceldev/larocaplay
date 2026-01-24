//
//  NotificationService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/1/26.
//

import Foundation
import Supabase

final class NotificationService {
    private let supabase = SupabaseClientInstance.shared.publicClient
    
    func fetchNotifications() async throws {
        
    }
    
    func marcAsRead(id: UUID) async throws {
        
    }
    
//    func updateDeviceToken(token: String) async throws {
//        try await supabase
//            .from("user_devices")
//
//    }
    func getCurrentSession() async throws -> Session {
        return try await supabase.auth.session
    }
    
    func registerDevice(device: UserDeviceDTO) async throws {
        try await supabase
            .from("user_devices")
            .upsert(device)
            .execute()
    }
    func deleteDevice(deviceId: String) async throws {
        try await supabase
            .from("user_devices")
            .delete()
            .eq("device_id", value: deviceId)
            .execute()
    }
    
    func getNotificationSettings(for userId: UUID) async throws -> UserNotificationSettingsDTO {
        try await supabase
            .from("user_notification_settings")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
    }
    func saveSettings(_ settings: UserNotificationSettingsDTO) async throws {
        try await supabase
            .from("user_notification_settings")
            .upsert(settings)
            .execute()
    }
}

//
//  PushNotificationService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/1/26.
//

import Foundation
import FirebaseMessaging
import Observation
import UIKit
import Supabase
import os

@Observable
final class PushNotificationService {
    static let shared = PushNotificationService()
    private let supabase = SupabaseClientInstance.shared.publicClient
    private let logger = Logger(subsystem: "com.anceldev.LaRocaPlay", category: "notifications")
    
    @MainActor
    func updateDeviceToken(fcmToken: String) async {
        guard let userId = try? await supabase.auth.session.user.id else {
//            print("No hay usuario autenticado. No se guarda el token")
            logger.notice("No hay usuario autenticado. No se guarda el token")
            return
        }
        let deviceName = UIDevice.current.name
        let deviceType = "ios"
        
        let deviceData: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "fcm_token": .string(fcmToken),
            "device_name": .string(deviceName),
            "device_type": .string(deviceType),
        ]
        
        do {
            try await supabase
                .from("user_devices")
                .upsert(deviceData, onConflict: "fcm_token")
                .execute()
            logger.info("Dispositivo registrado con éxito en Supabase")
            
        } catch {
            logger.error("Error al registrar el dispositivo: \(error)")
        }
    }
    
    @MainActor
    func removeDeviceToken() async {
        guard let token = Messaging.messaging().fcmToken else { return }
        do {
            try await supabase
                .from("user_devices")
                .delete()
                .eq("fcm_token", value: token)
                .execute()
            logger.info("[PushService] Dispositivo elminado al cerrar cesión")
        } catch {
            logger.error("[PushService] Error al eliminar el dispositivo: \(error)")
        }
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        if let type = userInfo ["type"] as? String, type == "new_preach" {
            let preachPath = handleNewPreach(data: userInfo)
            return
        }
    }
    private func handleNewPreach(data: [AnyHashable:Any]) -> CollectionItemFromNotification? {
        guard let preachIdString = data["preach_id"] as? String,
              let collectionIdString = data["collection_id"] as? String,
              let preachId = Int(preachIdString),
              let collectionId = Int(collectionIdString) else {
            return nil
        }
        return .init(preachId: preachId, collectionId: collectionId)
    }
}

//
//  NotificationManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/1/26.
//

import Foundation
import FirebaseMessaging
import SwiftData
import UIKit
import os


//@Observable
final class NotificationManager: NSObject {
    static let shared = NotificationManager(service: NotificationService())
    
    private let logger = Logger(subsystem: "com.anceldev.LaRocaPlay", category: "notifications")
    

    private let service: NotificationService
//    var notifications: [NotificationModel] = []
    var unreadCount: Int = 0
    
    private init(service: NotificationService) {
        self.service = service
    }
    
    
    func updateTokenInSupabase(token: String? = nil) {
        guard let fcmToken = token ?? Messaging.messaging().fcmToken else {
            return
        }
        logger.info("Enviando FCM token a Supabase: \(fcmToken)")
        Task {
            guard let session = try? await service.getCurrentSession() else { return }
            let userId = session.user.id
            
            let lastToken = UserDefaults.standard.string(forKey: "lastTokenKey")
            let lastUser = UserDefaults.standard.string(forKey: "lastUserKey")
            
            if fcmToken == lastToken && userId.uuidString == lastUser {
                logger.info("Token y usuario identocos, saltando update en Supabase")
                return
            }
            await registerDevice(userId: userId, token: fcmToken)
            
        }
    }
    
    private func registerDevice(userId: UUID, token: String) async {
        guard let device = await UIDevice.current.deviceId else {
            logger.warning("No device id found")
            return
        }
        let deviceName = await UIDevice.current.name
        do {
            let device = UserDeviceDTO(
                deviceId: device,
                userId: userId,
                fcmToken: token,
                deviceName: deviceName,
                deviceType: "ios"
            )
            try await service.registerDevice(device: device)
            UserDefaults.standard.set(token, forKey: "lastTokenKey")
            UserDefaults.standard.set(userId.uuidString, forKey: "lastUserKey")
            logger.info("Registro exitoso de dispositivo en user_devices")
        } catch {
            logger.error("Error en registro en user_devices: \(error)")
        }
    }
    func removeDeviceOnLogout() async {
        guard let deviceId = await UIDevice.current.deviceId else {
            return
        }
        do {
            try await service.deleteDevice(deviceId: deviceId)
            UserDefaults.standard.removeObject(forKey: "lastTokenKey")
            UserDefaults.standard.removeObject(forKey: "lastUserKey")
            logger.info("Dispositivo eliminado por logout")
        } catch {
            logger.error("No se pudo eliminar el dispositivo")
        }
    }
    func clearLocalCache() {
        UserDefaults.standard.removeObject(forKey: "lastTokenKey")
        UserDefaults.standard.removeObject(forKey: "lastUserKey")
        self.unreadCount = 0
    }
    
    func handleNotificationResponse(userInfo: [AnyHashable:Any]) {
        if let urlString = userInfo["url"] as? String, let url = URL(string: urlString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @MainActor
    func fetchAndSyncSettings(userId: UUID, context: ModelContext?) async {
        guard let context else { return }
        do {
            let dto = try await service.getNotificationSettings(for: userId)
            let settings = dto.toModel()
            context.insert(settings)
            var descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile> { $0.userId == userId })
            descriptor.fetchLimit = 1
            if let profile = try context.fetch(descriptor).first {
//                let settings = dto.toModel()
////                settings.userId = userId
//                context.insert(settings)
                profile.notificationSettings = settings
                try context.save()
            }
        } catch {
            logger.error("Error en sincronización de ajustes: \(error)")
        }
    }
    
    func saveSettingsToServer(_ settings: UserNotificationSettings) async {
        do {
            print(settings)
            try await service.saveSettings(settings.toDTO())
        } catch {
            logger.error("No se guardaron los ajustes; \(error)")
        }
    }
}

/**
 "¡Contraseña actualizada! Por seguridad, hemos cerrado las sesiones en tus otros dispositivos. Ya puedes disfrutar de La Roca Play."
 
 Para proteger tu cuenta, cerraremos todas las sesiones activas al solicitar el cambio
 */

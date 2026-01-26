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

enum NotificationTopic: String, CaseIterable {
    case notPreach = "new_preach" // Nueva predicación de domingo
    case notCollection = "new_collection" // Nueva colección pública
    case notPrivateCollection = "new_private_collection" // Nueva colección priada
    case notPublicCollectionItem = "new_public_collection_item" // Nuevo contenido en colección
    case notPrivateCollecitonItem = "new_private_collection_item" // Nuevo contenido en colección privada
    case notStreaming = "new_streaming"

}


//@Observable
final class NotificationManager: NSObject {
    static let shared = NotificationManager(service: NotificationService())
    
    private let logger = Logger(subsystem: "com.anceldev.LaRocaPlay", category: "notifications")
    

    private let service: NotificationService
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
    
    func removeDeviceOnLogout(collections: [Collection]) async {
        guard let deviceId = await UIDevice.current.deviceId else {
            return
        }
        do {
            try await service.deleteDevice(deviceId: deviceId)
            await unsubscriptTopicsOnLogout()
            
            let privateCollectionTopics: [String] = collections.compactMap { collection in
                "new_pci_cId_\(collection.id)"
            }
            await addOrRemovePrivateCollectionTopic(topics: privateCollectionTopics, subscribe: false)

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
    func setupNotificationTopics() async {
        do {
            for topic in NotificationTopic.allCases {
                try await Messaging.messaging().subscribe(toTopic: topic.rawValue)
            }
        } catch {
            logger.error("Error suscribiendose a topic: \(error)")
        }
    }
    
    @MainActor
    func unsubscriptTopicsOnLogout() async {
        do {
            for topic in NotificationTopic.allCases {
                try await Messaging.messaging().unsubscribe(fromTopic: topic.rawValue)
            }
        } catch {
            logger.error("Error desuscribiendo del topic: \(error)")
        }
    }
    func addOrRemovePrivateCollectionTopic(topics: [String], subscribe: Bool) async {
        do {
            for topic in topics {
                if subscribe {
                    try await Messaging.messaging().subscribe(toTopic: topic)
                } else {
                    try await Messaging.messaging().unsubscribe(fromTopic: topic)
                }
            }
        } catch {
            logger.error("No se pudo desuscribir de topic: \(error)")
        }
    }
    
    @MainActor
    func unsuscribeFromTopics(topics: [NotificationTopic]) async throws {
        for topic in topics {
            try await Messaging.messaging().unsubscribe(fromTopic: topic.rawValue)
            logger.info("Desuscrito de: \(topic.rawValue)")
        }
    }
    @MainActor
    func subscribeToTopics(topics: [NotificationTopic]) async throws {
        for topic in topics {
            try await Messaging.messaging().subscribe(toTopic: topic.rawValue)
            logger.info("Suscrito a: \(topic.rawValue)")
        }
    }
    
    @MainActor
    func fetchAndSyncSettings(userId: UUID, context: ModelContext?) async {
        guard let context else { return }
        do {
            let dto = try await service.getNotificationSettings(for: userId)
            
            var userDescriptor = FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile>{ $0.userId == userId })
            userDescriptor.fetchLimit = 1
            guard let profile = try context.fetch(userDescriptor).first else {
                logger.error("No se encontró el perfil para vincular los settings")
                return
            }
            
            if let existingSettings = profile.notificationSettings {
                if existingSettings.updatedAt > dto.updatedAt {
                    try await service.saveSettings(.init(from: existingSettings))
                } else if existingSettings.updatedAt < dto.updatedAt{
                    existingSettings.update(from: dto)
                }
                try await setupTopics(settings: existingSettings)
            } else {
                let newSettings = dto.toModel()
                context.insert(newSettings)
                profile.notificationSettings = newSettings
                try await setupTopics(settings: newSettings)
            }
            try context.save()
        } catch {
            logger.error("Error en sincronización de ajustes: \(error)")
        }
    }
    
    private func setupTopics(settings: UserNotificationSettings) async throws {
        let topics = syncCurrentNotificationTopics(settings: settings)
        try await subscribeToTopics(topics: topics)
    }
    @MainActor
    func saveSettingsToServer(_ settings: UserNotificationSettings) async {
        do {
            try await service.saveSettings(UserNotificationSettingsDTO(from: settings))
//            let topics = syncCurrentNotificationTopics(settings: settings)
//            try await subscribeToTopics(topics: topics)
//            try await unsuscribeFromTopics(topics: topics)
        } catch {
            logger.error("No se guardaron los ajustes; \(error)")
        }
    }
    private func syncCurrentNotificationTopics(settings: UserNotificationSettings) -> [NotificationTopic] {
        var topics: [NotificationTopic] = []
        if settings.newMainCollectionItem {
            topics.append(.notPreach)
        }
        if settings.newPublicCollection {
            topics.append(.notCollection)
        }
        if settings.newPrivateCollection {
            topics.append(.notPrivateCollection)
        }
        if settings.newPublicCollectionItem {
            topics.append(.notPublicCollectionItem)
        }
        if settings.newPrivateCollectionItem {
            topics.append(.notPrivateCollecitonItem)
        }
        if settings.youtubeLive {
            topics.append(.notStreaming)
        }
        return topics
    }
}

/**
 "¡Contraseña actualizada! Por seguridad, hemos cerrado las sesiones en tus otros dispositivos. Ya puedes disfrutar de La Roca Play."
 
 Para proteger tu cuenta, cerraremos todas las sesiones activas al solicitar el cambio
 */

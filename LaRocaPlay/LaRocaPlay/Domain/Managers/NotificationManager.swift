//
//  NotificationManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/1/26.
//

import Foundation

enum NotificationRoute: Equatable {
    case newPreach(id: Int, collectionId: Int)
    case newCollection(id: Int)
    case liveStream
}

@Observable
final class NotificationManager {
    static let shared = NotificationManager(service: NotificationService())

    private let service: NotificationService
//    var notifications: [NotificationModel] = []
    var unreadCount: Int = 0
    var pendingRoute: NotificationRoute?
    
    private init(service: NotificationService) {
        self.service = service
    }
    
    @MainActor
    func refresh() async {
        
    }
    
    func updateTokenInSupabase(token: String) {
    }
    
    func handleIngomingNotificatino(userInfo: [AnyHashable:Any]) {
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "new_preach":
            if let id = Int(userInfo["preach_id"] as? String ?? ""), let collectionId = Int(userInfo["collection_id"] as? String ?? "") {
                self.pendingRoute = .newPreach(id: id, collectionId: collectionId)
            }
        case "new_collection":
            if let id = Int(userInfo["collection_id"] as? String ?? "") {
                self.pendingRoute = .newCollection(id: id)
            }
        case "live_stream":
            self.pendingRoute = .liveStream
        default: break
        }
        
    }
}

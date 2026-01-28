//
//  Destination.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import AppRouter
import SwiftUI

enum Destination: DestinationType {
    case preachDetail(id: Int, isDeepLink: Bool = false)
    case preacher(preacher: PreacherDTO)
    case account
    case userDetails(UserProfile)
    case collections(String, String)
    case collection(id: Int, isDeepLink: Bool = false)
    case resetPassword
    case aboutUs
    case notificationSettings
    case myNotifications
    
    static func from(path: String, fullPath: [String], parameters: [String:String]) -> Destination? {
        guard let currentIndex = fullPath.firstIndex(of: path) else { return nil }
            var idValue: Int {
                let idIndex = currentIndex + 1
                if idIndex < fullPath.count {
                    return Int(fullPath[idIndex]) ?? 0
                }
                return 0
            }

            switch path {
            case "collection":
                return .collection(id: idValue, isDeepLink: true)
            case "preach":
                return .preachDetail(id: idValue, isDeepLink: true)
            default:
                return nil
            }
    }
}

enum Sheet: SheetType {
    case settings
    case profile
    case compose
    case auth
    var id: Int { hashValue }
}

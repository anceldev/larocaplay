//
//  Destination.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import AppRouter
import SwiftUI

enum Destination: DestinationType {
    case preach(preach: Preach)
    case preacher(preacher: PreacherDTO)
    case list
    case account
    case userDetails(UserProfile)
    case postDetail(id: String)     // Different from generic detail
    case collections(String, String)
    case collection(id: Int)
    case resetPassword
    case aboutUs
    //    case auth(user: User)
    //    case auth(user: User?)
    
//    static func from(path: String, fullPath: [String], parameters: [String : String]) -> Destination? {
//        guard let currenIndex = fullPath.firstIndex(of: path) else {
//            return nil
//        }
//        let previousComponent = currenIndex > 0 ? fullPath[currenIndex - 1] : nil
//        
//        switch (previousComponent, path) {
//        case ("users", "preach"):
//            let id = parameters["id"] ?? "unknown"
////            return .userDetails
//            return .account
//        case ("posts", "preach"):
//            let id = parameters["id"] ?? "unknown"
//            return .postDetail(id: id)
//            // Standard routing
//        case (_, "preach"):
//            let id = parameters["id"] ?? "default"
//            return .preach(preach: Preach(id: 299, title: "asd", date: .now, videoId: "asd"))
//        case (_, "list"):
//            return .list
//        case (_, "account"):
//            let userId = parameters["userId"] ?? "unknown"
//            return .account
//        case (nil, "users"), (nil, "posts"):
//            return nil // These are path segments, not destinations
//        default:
//            return nil
//        }
//    }
    
}
extension Destination {
    static func from(path: String, fullPath: [String], parameters: [String : String]) -> Destination? {
        return nil
    }
}

enum Sheet: SheetType {
    case settings
    case profile
    case compose
    case auth
    var id: Int { hashValue }
    
}

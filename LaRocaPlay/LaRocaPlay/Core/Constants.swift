//
//  Constants.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation

enum StorageCollections {
    case preachers(String?)
    case collections(String?)
    case preaches(String?)
    
    var associatedValue: String? {
        switch self {
        case    .preachers(let val),
                .collections(let val),
                .preaches(let val): return val
        }
    }
    
    var path: String {
        switch self {
        case .preachers(let thumbId):   "preacher/\(thumbId!)"
        case .collections(let thumbId): "collection/\(thumbId!)"
        case .preaches(let thumbId):    "preach/\(thumbId!)"
        }
    }
}

enum Constants {
    static let authRedirectUrl = "http://localhost:3000/auth/update-password"
    static let appAuthRedirectTo = "larocaplayapp://reset-password"
    
    static let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
    static let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$&*.,?+-]).{8,}$"
    static let mainCollectionId = 1
}

enum Queries: String {
    case collection = "id,title,description,image_id,collection_type_id(id, name),is_public,is_home_screen,created_at,updated_at"
    case collectionItem = """
                preach: preach_id (id,title,description,date,image_id,video_id,created_at,updated_at,
                preacher: preacher_id (id,name,preacher_role_id(id, name),image_id,created_at,updated_at)),
                position,id,created_at,updated_at
                """
    case shortCollectionItem = """
                preach: preach_id (id,date),
                id,updated_at
                """
    case preacher = "id,name,preacher_role_id(id, name),image_id,updated_at"
}

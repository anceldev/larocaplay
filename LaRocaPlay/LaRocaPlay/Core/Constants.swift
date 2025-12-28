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
        case .preachers(let preacherThumb):
            return preacherThumb
        case .collections(let collectionThumb):
            return collectionThumb
        case .preaches(let preachThumb):
            return preachThumb
        }
    }
    
    var path: String {
        switch self {
        case .preachers(let thumbId):
            "preachers/\(thumbId!)"
        case .collections(let thumbId):
            "collections/\(thumbId!)"
        case .preaches(let thumbId):
            "preaches/\(thumbId!)"
        }
    }
}


//
//  Congress.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

import Foundation

struct Congress: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let from: Date
    let to: Date
    let description: String?
    let thumbId: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id, name, from, to, description
        case thumbId = "thumb_id"
    }
}


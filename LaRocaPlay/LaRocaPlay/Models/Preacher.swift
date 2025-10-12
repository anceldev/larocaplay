//
//  Preacher.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

struct Preacher: Codable, Identifiable, Equatable, Hashable {
    var id: Int
    var name: String
    var role: String?
    let thumbId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, role
        case thumbId = "thumb_id"
    }
}

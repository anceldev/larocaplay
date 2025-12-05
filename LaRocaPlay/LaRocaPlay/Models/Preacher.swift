//
//  Preacher.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

struct Preacher: Codable, Identifiable, Equatable, Hashable {
    var id: Int
    var name: String
//    var role: String?
    var role: PreacherRole
    let thumbId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case role = "preacher_role_id"
        case thumbId = "thumb_id"
    }
}


struct PreacherRole: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
}

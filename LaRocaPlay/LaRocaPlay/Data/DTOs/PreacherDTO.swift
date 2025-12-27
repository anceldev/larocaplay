//
//  PreacherDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 19/8/25.
//

struct PreacherDTO: Codable, Identifiable, Equatable, Hashable {
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
    
    func toModel() -> Preacher {
        let model = Preacher(
            id: self.id,
            name: self.name,
            role: self.role.name,
            photoId: self.thumbId
        )
        return model
    }
}


struct PreacherRole: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
}

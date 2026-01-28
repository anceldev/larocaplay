//
//  PreachDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation
//import JSONCodable


protocol PreachProtocol: Identifiable, Codable {
    var id: Int { get set }
    var title: String { get set }
    var description: String? { get set }
    var date: Date { get set }
    var preacher: PreacherDTO { get set }
    var videoId: String { get set }
    var imageId: String? { get set }
    
    
}

struct ShortPreachDTO: Decodable {
    var id: Int
    var date: Date
//    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, date
//        case updatedAt = "updated_at"
    }
}

struct PreachDTO: PreachProtocol, Hashable {
    var id: Int
    var title: String
    var description: String?
    var date: Date
    var preacher: PreacherDTO
    var videoId: String
    var imageId: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, date
        case videoId = "video_id"
        case preacher = "preacher"
        case serie = "serie_id"
        case imageId = "image_id"
        case collection = "collection_id"
        case discipleship = "discipleship_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: Int, title: String, description: String? = nil, date: Date = .now, preacher: PreacherDTO, videoUrl: String, imageId: String? = nil, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.preacher = preacher
        self.videoId = videoUrl
        self.imageId = imageId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.preacher = try container.decode(PreacherDTO.self, forKey: .preacher)

        let stringDate = try container.decode(String.self, forKey: .date)
        guard let date = DateFormatter.decodedSupabaseDate(stringDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Wrong date format")
        }
        self.date = date
        
        let createdString = try container.decode(String.self, forKey: .createdAt)
        guard let decodedCreatedDate = DateFormatter.decodedSupabaseDate(createdString)else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "wrong created_at format")
        }
        self.createdAt = decodedCreatedDate
        
        let updateString = try container.decode(String.self, forKey: .updatedAt)
        
        guard let decodedUpdatedDate = DateFormatter.decodedSupabaseDate(updateString) else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "wrong updated_at format")
        }
        self.updatedAt = decodedUpdatedDate
        
        self.videoId = try container.decode(String.self, forKey: .videoId)
        self.imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
    }
    func encode(to encoder: any Encoder) throws {
        
    }
    
    func toModel() -> Preach {
        let model = Preach(
            id: self.id,
            title: self.title,
            desc: self.description,
            date: self.date,
            videoId: self.videoId,
            imageId: self.imageId,
            updatedAt: self.updatedAt
        )
        return model
    }
}



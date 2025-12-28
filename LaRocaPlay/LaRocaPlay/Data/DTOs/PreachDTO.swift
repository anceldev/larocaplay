//
//  PreachDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation
import JSONCodable

protocol PreachProtocol: Identifiable, Codable {
    var id: Int { get set }
    var title: String { get set }
    var description: String? { get set }
    var date: Date { get set }
    var preacher: PreacherDTO { get set }
    var videoUrl: String { get set }
    var thumbId: String? { get set }
    
    
}

struct PreachDTO: PreachProtocol, Hashable {
    var id: Int
    var title: String
    var description: String?
    var date: Date
    var preacher: PreacherDTO
    var videoUrl: String
    var thumbId: String?
    
    
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, date
        case videoUrl = "video_url"
//        case preacher = "preacher_id"
        case preacher = "preacher"
        case serie = "serie_id"
        case thumbId = "thumb_id"
        case collection = "collection_id"
        case discipleship = "discipleship_id"
        case updatedAt = "updated_at"
    }
    
    init(id: Int, title: String, description: String? = nil, date: Date = .now, preacher: PreacherDTO, videoUrl: String, thumbId: String? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.preacher = preacher
        self.videoUrl = videoUrl
        self.thumbId = thumbId
        self.updatedAt = updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.preacher = try container.decode(PreacherDTO.self, forKey: .preacher)

        let stringDate = try container.decode(String.self, forKey: .date)
        guard let date = DateFormatter.supabaseDate.date(from: stringDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Wrong date format")
        }
        self.date = date
        let updateString = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        guard let updateString, let updatedDate = DateFormatter.supabaseTimestamp.date(from: updateString) else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Wrong updatedAt date format")
        }
        self.updatedAt = updatedDate
        
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
        self.thumbId = try container.decodeIfPresent(String.self, forKey: .thumbId)
    }
    func encode(to encoder: any Encoder) throws {
        
    }
    
    func toModel() -> Preach {
        let model = Preach(
            id: self.id,
            title: self.title,
            desc: self.description,
            date: self.date,
            videoId: self.videoUrl,
            imageId: self.thumbId,
            updatedAt: self.updatedAt
        )
        return model
    }
}



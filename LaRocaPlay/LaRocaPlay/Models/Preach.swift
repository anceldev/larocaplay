//
//  Preach.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation

protocol PreachProtocol: Identifiable, Codable {
    var id: Int { get set }
    var title: String { get set }
    var description: String? { get set }
    var date: Date { get set }
    var preacher: Preacher { get set }
    var videoUrl: String { get set }
    var thumbId: String? { get set }
}

struct Preach: PreachProtocol, Hashable {
    var id: Int
    var title: String
    var description: String?
    var date: Date
    var preacher: Preacher
    var videoUrl: String
    var thumbId: String?
    
    var serie: PreachCollection?
    var collection: PreachCollection?
    var discipleship: PreachCollection?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, date
        case videoUrl = "video_url"
//        case preacher = "preacher_id"
        case preacher = "preacher"
        case serie = "serie_id"
        case thumbId = "thumb_id"
        case collection = "collection_id"
        case discipleship = "discipleship_id"
    }
    
    init(id: Int, title: String, description: String? = nil, date: Date = .now, preacher: Preacher, videoUrl: String, serie: PreachCollection? = nil, thumbId: String? = nil, collection: PreachCollection? = nil, discipleship: PreachCollection? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.preacher = preacher
        self.videoUrl = videoUrl
        self.thumbId = thumbId
        self.serie = serie
        self.collection = collection
        self.discipleship = discipleship
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.preacher = try container.decode(Preacher.self, forKey: .preacher)

        let stringDate = try container.decode(String.self, forKey: .date)
        guard let date = DateFormatter.supabaseDate.date(from: stringDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Wrong date format")
        }
        self.date = date
        
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
        self.serie = try container.decodeIfPresent(PreachCollection.self, forKey: .serie)
        self.thumbId = try container.decodeIfPresent(String.self, forKey: .thumbId)
        self.collection = try container.decodeIfPresent(PreachCollection.self, forKey: .collection)
        self.discipleship = try container.decodeIfPresent(PreachCollection.self, forKey: .discipleship)
    }
    func encode(to encoder: any Encoder) throws {
        
    }
}

extension DateFormatter {
    static let supabaseDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let supabaseTimestamp: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSxxxxx"
           formatter.timeZone = TimeZone(secondsFromGMT: 0)
           formatter.locale = Locale(identifier: "en_US_POSIX")
           return formatter
       }()
}


//
//  Preach.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation

struct Preach: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let preacher: Preacher?
    let date: Date
    let video: String
    let serie: Serie?
    let thumbdId: String?
    let congress: Congress?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, video, date
//        case serie = "serie_id"
        case preacher = "preacher_id"
        case serie = "serie_id"

//        case preacher = "preacher_id"
        case thumbId = "thumb_id"
        case congress = "congress_id"
//        case preacher, date, video, serie, thumb
    }
    
    init(id: Int, title: String, description: String? = nil, date: Date = .now, preacher: Preacher? = nil, video: String, serie: Serie? = nil, thumbId: String? = nil, congress: Congress? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.preacher = preacher
        self.video = video
        self.serie = serie
        self.thumbdId = thumbId
        self.congress = congress
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.preacher = try container.decodeIfPresent(Preacher.self, forKey: .preacher)
        // Space for date
//        self.date = try container.decode(Date.self, forKey: .date)
        let stringDate = try container.decode(String.self, forKey: .date)
//        self.date = Date(from: D)
        guard let date = DateFormatter.supabaseDate.date(from: stringDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Wrong date format")
        }
        self.date = date
        
        self.video = try container.decode(String.self, forKey: .video)
        self.serie = try container.decodeIfPresent(Serie.self, forKey: .serie)
        self.thumbdId = try container.decodeIfPresent(String.self, forKey: .thumbId)
        self.congress = try container.decodeIfPresent(Congress.self, forKey: .congress)
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

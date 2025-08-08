//
//  Preach.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation

struct Preach: Codable, Identifiable, Hashable {
    var id: String
    let title: String
    var preacher: String
    var date: Date
    var video: URL
    var serie: String?
    var thumb: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case title, preacher, date, video, serie, thumb
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.preacher = try container.decode(String.self, forKey: .preacher)
//        self.date = try container.decode(Date.self, forKey: .date)
        let documentDate = try container.decode(String.self, forKey: .date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        self.date = formatter.date(from: documentDate) ?? .now
        
        self.video = try container.decode(URL.self, forKey: .video)
        self.serie = try container.decodeIfPresent(String.self, forKey: .serie)
        self.thumb = try container.decodeIfPresent(URL.self, forKey: .thumb)
    }
}

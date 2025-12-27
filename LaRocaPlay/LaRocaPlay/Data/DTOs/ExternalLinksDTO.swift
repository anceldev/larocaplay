//
//  ExternalLinks.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import Foundation

struct ExternalLinkDTO: Decodable {
    let id: Int
    let key: String
    let link: String?
    let enabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, key, link, enabled
    }
}

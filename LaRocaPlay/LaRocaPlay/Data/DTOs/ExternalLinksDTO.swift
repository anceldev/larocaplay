//
//  ExternalLinks.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import Foundation

struct ExternalLinkDTO: Decodable {
    let id: Int
    let keyLink: String
    let link: String?
    let isEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, link
        case keyLink = "key_link"
        case isEnabled = "is_enabled"
    }
}

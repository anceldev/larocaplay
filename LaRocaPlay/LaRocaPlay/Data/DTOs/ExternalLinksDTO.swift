//
//  ExternalLinks.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import Foundation

struct ExternalLinkDTO: Decodable, Identifiable {
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

extension ExternalLinkDTO {
    static let constants: [ExternalLinkDTO] = [
        .init(id: 1, keyLink: "youtube", link: "https://www.youtube.com/@CentroCristianoLaRoca", isEnabled: true),
        .init(id: 2, keyLink: "instagram", link: "https://www.instagram.com/cclaroca_va?igsh=aGplamt3cWptZnJl", isEnabled: true),
        .init(id: 3, keyLink: "tiktok", link: "https://www.tiktok.com/@cclaroca_va", isEnabled: true)
    ]
}

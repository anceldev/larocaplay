//
//  ExternalLinkDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import SwiftData

@Model
final class ExternalLink {
    @Attribute(.unique) var id: Int
    var key: String
    var link: String
    var enabled: Bool
    
    init(id: Int, key: String, link: String, enabled: Bool) {
        self.id = id
        self.key = key
        self.link = link
        self.enabled = enabled
    }
}

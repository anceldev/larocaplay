//
//  VimeoVideoCache.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 22/12/25.
//

import Foundation
import SwiftData

@Model
final class VimeoVideoCache {
    var videoId: String
    var link: String
    var linkExpirationTime: Date
    
    init(videoId: String, link: String, linkExpirationTime: Date) {
        self.videoId = videoId
        self.link = link
        self.linkExpirationTime = linkExpirationTime
    }
}

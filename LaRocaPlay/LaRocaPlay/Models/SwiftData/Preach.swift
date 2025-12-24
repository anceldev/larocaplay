//
//  Preach.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation
import SwiftData

@Model
final class Preach {
    @Attribute(.unique) var id: Int
    var title: String
    var desc: String?
    var date: Date
    var videoId: String
    var imageId: String?
    
    var preacher: Preacher?
    var collections: [Collection]?
    
    init(id: Int, title: String, desc: String? = nil, date: Date, videoId: String, imageId: String? = nil, preacher: Preacher? = nil, collections: [Collection]? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
        self.videoId = videoId
        self.imageId = imageId
        self.preacher = preacher
        self.collections = collections
    }
}

//
//  CollectionItemResponseDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import SwiftData

struct CollectionItemResponseDTO: Decodable {
    let id: Int
    let preach: PreachDTO
    let position: Int?
}

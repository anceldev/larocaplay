//
//  Card.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/1/26.
//

import Foundation

struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var image: String
}
let cards: [Card] = [
    .init(image: "Pic 1"),
    .init(image: "Pic 2"),
    .init(image: "Pic 3"),
    .init(image: "Pic 4"),
]

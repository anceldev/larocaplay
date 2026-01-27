//
//  ShortResponseDTO.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/1/26.
//

import Foundation

struct ShortResponseDTO: Identifiable, Decodable {
    var id: Int
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let dateString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let updatedDate = formatter.date(from: dateString) {
            self.updatedAt = updatedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let updatedDate = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Fecha inválida")
            }
            self.updatedAt = updatedDate
        }
    }
}

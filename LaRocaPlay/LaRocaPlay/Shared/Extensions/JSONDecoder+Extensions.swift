//
//  JSONDecoder+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 22/12/25.
//

import Foundation

extension JSONDecoder {
    static var supabaseDateDecoder: JSONDecoder = {
       let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.supabase)
        return decoder
    }()
}

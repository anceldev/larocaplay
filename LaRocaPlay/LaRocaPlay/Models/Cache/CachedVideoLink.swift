//
//  CachedVideoLink.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import Foundation

struct CachedVideoLink {
    let url: URL
    let expirationDate: Date
    var isValid: Bool {
        Date() < expirationDate.addingTimeInterval(-(2 * 3600)) // Expira en 22 horas
    }
}

//
//  Bool+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import Foundation

extension Bool {
    static var iOS26: Bool {
        guard #available(iOS 26.0, *) else {
            return true
        }
        return false
    }
}

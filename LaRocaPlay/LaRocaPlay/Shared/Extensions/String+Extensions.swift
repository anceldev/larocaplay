//
//  String+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import Foundation

extension String {
    func truncated(limit: Int = 25) -> String {
        if self.count > limit {
            return String(self.prefix(limit - 3)) + "..."
        }
        return self
    }
}

//
//  Bundle+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 10/1/26.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}

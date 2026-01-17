//
//  UIDevice+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/1/26.
//

import Foundation
import UIKit

extension UIDevice {
    var deviceId: String? {
        return identifierForVendor?.uuidString
    }
}

//
//  Theme.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import Foundation
import SwiftUI

struct Theme {
    struct Radius {
        static let small: CGFloat =     16
        static let medium: CGFloat =    20
        static let large: CGFloat =     22
        static let player: CGFloat =    30
    }
    
    struct Padding {
        static let tight: CGFloat =     4
        static let normal: CGFloat =    18
        static let wide: CGFloat =      24
    }
    
    struct Button {
        static let disabled: Color = .gray.opacity(0.5)
        static let normal: Color = .customRed
    }
}

enum ListView {
    case single
    case grid
    case list
    
    var titleSize: CGFloat {
        switch self {
        case .single:   20
        case .grid:     14
        case .list:     14
        }
    }
    var subtitleSize: CGFloat {
        switch self {
        case .single:   14
        case .grid:     10
        case .list:     12
        }
    }
    var textAlignment: Alignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
        }
    }
    var textPadding: CGFloat {
        switch self {
        case .single:   8
        case .grid:     8
        case .list:     0
        }
    }
    var tAlignment: TextAlignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
            
        }
    }
    var hAlignment: HorizontalAlignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
        }
    }
    var colSpacing: CGFloat {
        switch self {
        case .single:   20
        case .grid:     14
        case .list:     8
        }
    }
}

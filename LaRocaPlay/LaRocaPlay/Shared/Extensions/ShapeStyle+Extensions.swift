//
//  ShapeStyle+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 28/1/26.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static var appBackground: AppBackground { .init() }
    static var appLabel: AppLabel { .init() }
}

struct AppBackground {
    let primary = Color.bgPrimary
    let secondary = Color.bgSecondary
}

struct AppLabel {
    let primary = Color.labelPrimary
    let secondary = Color.labelSecondary
}

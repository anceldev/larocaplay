//
//  AppTab.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import AppRouter

enum AppTab: String, TabType, CaseIterable {
    case home, preaches, store
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .preaches: return "book"
        case .store: return "cart"
        }
    }
}

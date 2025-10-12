//
//  AppTab.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/8/25.
//

import AppRouter

enum AppTab: String, TabType, CaseIterable {
    case home, preaches, training, karaoke, store
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house-2"
        case .preaches: return "heart"
        case .karaoke: return "microphone"
        case .store: return "cart-shopping"
        case .training: return "book-open"
        }
    }
    var label: String {
        switch self {
        case .home: return "Inicio"
        case .preaches: return "Predicaciones"
        case .training: return "Capacitaciones"
        case .karaoke: return "Karoke"
        case .store: return "Tienda"
        }
    }
}

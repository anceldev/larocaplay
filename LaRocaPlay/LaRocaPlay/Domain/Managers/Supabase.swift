//
//  Supabase.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 8/8/25.
//

import Foundation
import Supabase
import Observation
import ConfidentialKit

@Observable
final class SBCLient {
    var supabase: SupabaseClient
    
    private init() {
        // Initialize with nil, will be set up later
        let anonKey = "\(Secrets.$supabaselocalkey)"
        let projectUrl = "\(Secrets.$supabaselocalurl)"
        
//        let anonKey = "\(Secrets.$supabaseanonkey)"
//        let projectUrl = "\(Secrets.$supabaseprojecturl)"
        supabase = .init(
//            supabaseURL: URL(string: projectUrl)!,
            supabaseURL: URL(string: "http://192.168.1.11:54321")!,
            supabaseKey: anonKey
        )
        
    }
}

extension SBCLient {
    static let shared = SBCLient()
}

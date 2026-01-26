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
final class SupabaseClientInstance {
    var publicClient: SupabaseClient
    
    private init() {
//        let projectUrl = URL(string: "\(Secrets.$supabaselocalurl)")!
//        let anonKey = "\(Secrets.$supabaselocalkey)"
        let projectUrl = URL(string: "\(Secrets.$supabaseprojecturl)")!
        let anonKey = "\(Secrets.$supabaseanonkey)"
        
        publicClient = .init(
//            supabaseURL: URL(string: projectUrl)!,
//            supabaseURL: URL(string: "http://172.20.10.2:54321")!,
//            supabaseURL: URL(string: "http://192.168.1.17:54321")!,
            supabaseURL: projectUrl,
            supabaseKey: anonKey
        )
    }
}

extension SupabaseClientInstance {
    static let shared = SupabaseClientInstance()
}

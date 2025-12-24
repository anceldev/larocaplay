//
//  CelebrationRepository.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 3/12/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class CelebrationRepository {
    let client = SBCLient.shared.supabase
    var preaches = [PreachDTO]()
    var indexFrom = 0
    var indexTo = 4
    var isInitialized = false
    var isFull = false
    private var itemLimit = 5
    
    @MainActor
    init() {
        Task {
            try await getCelebrationPreaches()
        }
    }
    func getCelebrationPreaches() async throws {
        if isFull { return }
        let newPreaches: [PreachCollectionWrapper] = try await client
            .from("preach_collection_membership")
            .select("""
                preach:preach_id (
                    id,
                    title,
                    description,
                    date,
                    video_url,
                    preacher:preacher_id(
                        id,
                        name,
                        preacher_role_id(id, name),
                        thumb_id
                        )
                )
                """)
            .eq("collection_id", value: 1)
            .order("preach(date)", ascending: false)
            .range(from: indexFrom, to: indexTo)
            .execute()
            .value
        
        
        if newPreaches.count < self.itemLimit {
            self.isFull = true
        }
        self.indexFrom = self.preaches.count + newPreaches.count
        self.indexTo = self.indexFrom + self.itemLimit
        
        let newMappedPreaches = newPreaches.map ({ $0.preach }).sorted { $0.date > $1.date }
        if self.isInitialized {
            self.preaches.append(contentsOf: newMappedPreaches)
            return
        }
        self.preaches = newMappedPreaches
        self.isInitialized = true
    }
}

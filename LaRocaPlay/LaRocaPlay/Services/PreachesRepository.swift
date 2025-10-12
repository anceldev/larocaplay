//
//  PreachesRepository.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class PreachesRepository {
    let client = SBCLient.shared.supabase
    var preaches = [Preach]()
    private var itemLimit = 5
//    var preaches: [Preach]
    var indexfrom: Int = 0
    var indexTo: Int = 5
    var isInitialized = false
    var isFull = false
    
    @MainActor
    init() {
        Task {
            do {
                let newPreaches = try await getPreaches()
                self.preaches.append(contentsOf: newPreaches)
                self.isInitialized = true
            } catch {
                print("No preached founded")
            }
        }
    }
    
    
    func getPreaches() async throws -> [Preach] {
        do {
//            let new = try await client
//                .from("preaches")
//                .select("""
//                    id,
//                    title,
//                    description,
//                    preacher_id(id, name, role),
//                    date,
//                    video,
//                    serie_id(id, name, description, thumb_id)
//                    thumb_id,
//                    congress_id(id, name, from, to, description, thumb_id)
//                    """)
//                .lte("date", value: Date())
//                .order("date", ascending: false)
//                .range(from: indexfrom, to: indexTo)
//                .execute()
            
//            print(try JSONSerialization.jsonObject(with: new.data))
            
            let newPreaches: [Preach] = try await client
                .from("preaches")
                .select("""
                    id,
                    title,
                    description,
                    preacher_id(id, name, role),
                    date,
                    video,
                    serie_id(id, created_at, name, description, thumb_id)
                    thumb_id,
                    congress_id(id, name, from, to, description, thumb_id)
                    """)
                .lte("date", value: Date())
                .order("date", ascending: false)
                .range(from: indexfrom, to: indexTo)
                .execute()
                .value
//            let newPreaches = [Preach]()
            
            
            if newPreaches.count < self.itemLimit {
                self.isFull = true
            }
            self.indexfrom = self.preaches.count + newPreaches.count
            self.indexTo = self.indexfrom + self.itemLimit
            if self.isInitialized {
                self.preaches.append(contentsOf: newPreaches)
            }
            return newPreaches
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}


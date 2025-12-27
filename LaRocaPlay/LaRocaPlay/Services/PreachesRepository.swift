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
    var preaches = [PreachDTO]()
    var externalLinks = [ExternalLinkDTO]()
    
    private var itemLimit = 5
//    var preaches: [Preach]
    var indexfrom: Int = 0
    var indexTo: Int = 4
    var isInitialized = false
    var isFull = false
    
    @MainActor
    init() {
        Task {
            do {
                let newPreaches = try await getPreaches()
                self.preaches.append(contentsOf: newPreaches)
                self.externalLinks = try await getExternalLinks()
                self.isInitialized = true
            } catch {
                print("No preached founded")
            }
        }
    }
    
    func getExternalLinks() async throws -> [ExternalLinkDTO]{
        let links: [ExternalLinkDTO] = try await client
            .from("external_links")
            .select()
            .execute()
            .value
        return links
    }
    
    
    func getPreaches() async throws -> [PreachDTO] {
        do {
            let newPreaches: [PreachDTO] = try await client
                .from("preach")
                .select("""
                    id,
                    title,
                    description,                    
                    date,
                    video_url,
                    thumb_id,
                    preacher_id(id, name)
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


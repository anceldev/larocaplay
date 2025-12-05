//
//  CollectionRepository.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class CollectionRepository {
    let client = SBCLient.shared.supabase
    var series: [PreachCollection] = []
    
    @MainActor
    init(){
        Task {
            do {
                try await getCollections()
            } catch {
                print("No se encontraron series")
                throw error
            }
        }
    }
    
    func getCollections() async throws {
        do {
            let collections: [PreachCollection] = try await client
                .from("preach_collection")
                .select("""
                    id,
                    title,
                    description,
                    thumb_id,
                    collection_type_id(id, name),
                    is_public,
                    created_at
                    """)
                .neq("id", value: 1)
                .order("created_at", ascending: true)
                .execute()
                .value
            self.series = collections
        } catch {
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    func getSeriePreachesFromTo(serieId: Int, from: Int, to: Int) async throws {
        let indexSerie = series.firstIndex { $0.id == serieId }
        guard let indexSerie else { return }
        if series[indexSerie].preaches.count > 0 {
            return
        } else {
            let preaches:[PreachCollectionWrapper] = try await client
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
                .eq("collection_id", value: serieId)
                .range(from: from, to: to)
                .execute()
                .value
            
            let mappedPreaches = preaches.map { $0.preach }.sorted { $0.date > $1.date }
            series[indexSerie].preaches = mappedPreaches
        }
    }
    
    func getSeriePreaches(serieId: Int) async throws {
        let indexSerie = series.firstIndex { $0.id == serieId }
        guard let indexSerie else { return }
        if series[indexSerie].preaches.count > 0 {
            return
        } else {
            let preaches:[PreachCollectionWrapper] = try await client
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
                .eq("collection_id", value: serieId)
                .execute()
                .value
            
            let mappedPreaches = preaches.map { $0.preach }.sorted { $0.date > $1.date }
            series[indexSerie].preaches = mappedPreaches
        }
    }
    
    func getLessons(serieId: Int) async throws -> [Preach] {
        return []
    }
}

//
//  SeriesRepository.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class SeriesRepository {
    let client = SBCLient.shared.supabase
    var series: [Serie] = []
    
    @MainActor
    init(){
        Task {
            do {
                try await getSeries()
            } catch {
                print("No se encontraron series")
                throw error
            }
        }
    }
    private func getSeries() async throws {
        let series: [Serie] = try await client
            .from("series")
            .execute()
            .value
        self.series = series
    }
    func getLessons(serieId: Int) async throws -> [Preach] {
        let lessons: [Preach] = try await client
            .from("preaches")
            .select("""
                id,
                title,
                description,
                preacher_id(id, name, role),
                date,
                video,
                thumb_id
                """)
            .eq("serie_id", value: serieId)
            .execute()
            .value
        
        return lessons
    }
}

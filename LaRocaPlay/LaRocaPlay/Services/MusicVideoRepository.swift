//
//  MusicRepository.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import Foundation
import Observation
import Supabase

@Observable
final class MusicVideoRepository {
    let client = SBCLient.shared.supabase
//    var music: [MusicItem] = []
    var songs = [MusicVideo]()
    
    @MainActor
    init() {
        Task {
            do {
                try await getSongs()
            } catch {
                print("No music founded")
                throw error
            }
        }
    }
    
    func getSongs() async throws {
        let list: [MusicVideo] = try await client
            .from("music_video")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        print(list)
        self.songs = list
    }
}

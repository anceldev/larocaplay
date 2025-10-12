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
final class MusicRepository {
    let client = SBCLient.shared.supabase
    var music: [MusicItem] = []
    
    @MainActor
    init() {
        Task {
            do {
                try await getPlaylist()
            } catch {
                print("No music founded")
                throw error
            }
        }
    }
    
    func getPlaylist() async throws {
        let list: [MusicItem] = try await client
            .from("music_list")
            .execute()
            .value
        self.music = list
    }
}

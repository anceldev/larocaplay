//
//  File.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 16/12/25.
//

import Foundation
import Supabase


//@Observable
//final class PreachesService {
//    let client = SBCLient.shared.supabase
//    
////    
////    func getPreachVideo() async -> URL {
////        do {
////            let videoLink = getTEm
////        } catch {
////            
////        }
////    }
//    
//    
//    private func saveTemporalVideoLink(for video: VimeoVideoPlayProgressive, with videoId: String) async throws {
//        let newVideoLink: SupabaseVideo = .init(
//            videoId: videoId,
//            videoLink: video.link!,
//            linkExpirationTime: video.linkExpirationTime
//        )
//        let save = try await client
//            .from("video_temporal_link")
//            .insert(newVideoLink)
//            .select()
//            .execute()
//
//        print(save)
//    }
//    
//    
//    private func getTemporalVideoLink(for videoId: String) async throws -> URL? {
//        let video: SupabaseVideo = try await client
//            .from("video_temporal_link")
//            .select()
//            .eq("video_id", value: videoId)
//            .execute()
//            .value
//        
//        return URL(string: video.videoLink)
//    }
//}

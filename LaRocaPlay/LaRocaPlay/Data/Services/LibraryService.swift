//
//  LibraryService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import Supabase

final class LibraryService {
    private let supabaseClient = SBCLient.shared.supabase
    
    
    func fetchCollections() async throws -> [CollectionDTO] {
        try await supabaseClient
            .from("collection")
            .select("""
                id,
                title,
                description,
                thumb_id,
                collection_type_id(id, name),
                is_public,
                is_home_screen,
                created_at
                """)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
//    func fetchTeachings(collectionId: Int, limit: Int, offset: Int) async throws -> [PreachDTO] {
//        let teachings: [PreachCollectionWrapper] = try await supabaseClient
//            .from("preach_collection_membership")
//            .select("""
//                preach: preach_id (
//                    id,
//                    title,
//                    description,
//                    date,
//                    thumb_id,
//                    video_url,
//                    preacher: preacher_id (
//                        id,
//                        name,
//                        preacher_role_id(id, name),
//                        thumb_id
//                        )
//                ),
//                position
//                """)
//            .eq("collection_id", value: collectionId)
//            .range(from: offset, to: limit)
//            .execute()
//            .value
//        let mappedTeachings = teachings.map { $0.preach }.sorted { $0.date > $1.date }
//        return mappedTeachings
//    }
    func fetchTeachings(collectionId: Int, limit: Int, offset: Int) async throws -> [CollectionPreachResponseDTO] {
        try await supabaseClient
            .from("preach_collection_membership")
            .select("""
                preach: preach_id (
                    id,
                    title,
                    description,
                    date,
                    thumb_id,
                    video_url,
                    updated_at,
                    preacher: preacher_id (
                        id,
                        name,
                        preacher_role_id(id, name),
                        thumb_id
                        )
                ),
                position,
                id
                """)
            .eq("collection_id", value: collectionId)
//            .range(from: offset, to: limit)
            .execute()
            .value
//        let data = try await supabaseClient
//            .from("preach_collection_membership")
//            .select("""
//                preach: preach_id (
//                    id,
//                    title,
//                    description,
//                    date,
//                    thumb_id,
//                    video_url,
//                    updated_at,
//                    preacher: preacher_id (
//                        id,
//                        name,
//                        preacher_role_id(id, name),
//                        thumb_id
//                        )
//                ),
//                position,
//                id
//                """)
//            .eq("collection_id", value: collectionId)
//            .range(from: offset, to: limit)
//            .execute()
//        let mappedTeachings = teachings.map { $0.preach }.sorted { $0.date > $1.date }
//        return mappedTeachings
    }
    
    func fetchAllPreachers() async throws -> [PreacherDTO] {
        try await supabaseClient
            .from("preacher")
            .select("""
                id,
                name,
                preacher_role_id(id, name),
                thumb_id
                """)
            .execute()
            .value
    }
    func fetchCollectionTypes() async throws -> [PreachCollectionType] {
        let data: [PreachCollectionType] = try await supabaseClient
            .from("collection_type")
            .select("*")
            .execute()
            .value
        print(data)
        return data
    }
}

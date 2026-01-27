//
//  LibraryService.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import Supabase

enum SupabaseTable: String {
    case collection
    case collectionItem = "collection_item"
}



final class LibraryService {
    private let supabaseClient = SupabaseClientInstance.shared.publicClient
    
    
    func fetchShortData<T:Decodable>(for table: SupabaseTable) async throws -> [T] {
        try await supabaseClient
            .from(table.rawValue)
            .select("id, updatedAt")
            .execute()
            .value
    }
    
    func fetchCollections() async throws -> [CollectionDTO] {
        try await supabaseClient
            .from("collection")
            .select("""
                id,
                title,
                description,
                image_id,
                collection_type_id(id, name),
                is_public,
                is_home_screen,
                created_at,
                updated_at
                """)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
    func fetchCollections(with ids: [Int]) async throws -> [CollectionDTO] {
        try await supabaseClient
            .from("collection")
            .select("""
                id,
                title,
                description,
                image_id,
                collection_type_id(id, name),
                is_public,
                is_home_screen,
                created_at,
                updated_at
                """)
            .eq("id", value: ids)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    func fetchCollection(id: Int) async throws -> CollectionDTO {
        try await supabaseClient
            .from("collection")
            .select("""
                id,
                title,
                description,
                image_id,
                collection_type_id(id, name),
                is_public,
                is_home_screen,
                created_at,
                updated_at
                """)
            .eq("id", value: id)
            .single()
            .execute()
            .value
            
    }
    
    func fetchTeachings(collectionId: Int, limit: Int, offset: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                    id,
                    title,
                    description,
                    date,
                    image_id,
                    video_id,
                    created_at,
                    updated_at,
                    preacher: preacher_id (
                        id,
                        name,
                        preacher_role_id(id, name),
                        image_id,
                        created_at,
                        updated_at
                        )
                ),
                position,
                id,
                created_at,
                updated_at
                """)
            .eq("collection_id", value: collectionId)
            .order("preach(date)", ascending: false)
//            .limit(limit)
            .range(from: 0, to: limit)
            .execute()
            .value
    }
    
    
    
    func fetchShortTeachings(colId: Int, limit: Int, offset: Int) async throws -> [ShortCollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                id,
                date
                ),
                id,
                updated_at
                """)
            .eq("collection_id", value: colId)
            .order("preach(date)", ascending: false)
            .range(from: 0, to: limit)
            .execute()
            .value
    }
    
//    func fetchTeachings(colId: Int, limit: Int, offset: Int) async throws -> [CollectionItemResponseDTO] {
//        try await supabaseClient
//            .from("collection_item")
//            .select("""
//                preach: preach_id (
//                    id,
//                    title,
//                    description,
//                    date,
//                    image_id,
//                    video_id,
//                    created_at,
//                    updated_at,
//                    preacher: preacher_id (
//                        id,
//                        name,
//                        preacher_role_id(id, name),
//                        image_id,
//                        created_at,
//                        updated_at
//                        )
//                ),
//                position,
//                id,
//                created_at,
//                updated_at
//                """)
//            .eq("collection_id", value: colId)
//    }
    
    func fetchTeachingsWithoutLimit(collectionId: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                    id,
                    title,
                    description,
                    date,
                    image_id,
                    video_id,
                    created_at,
                    updated_at,
                    preacher: preacher_id (
                        id,
                        name,
                        preacher_role_id(id, name),
                        image_id,
                        created_at,
                        updated_at
                        )
                ),
                position,
                id,
                created_at,
                updated_at
                """)
            .eq("collection_id", value: collectionId)
            .execute()
            .value
        
    }
    func fetchCollecitonItemsWithIds(for ids: [Int]) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                    id,
                    title,
                    description,
                    date,
                    image_id,
                    video_id,
                    created_at,
                    updated_at,
                    preacher: preacher_id (
                        id,
                        name,
                        preacher_role_id(id, name),
                        image_id,
                        created_at,
                        updated_at
                        )
                ),
                position,
                id,
                created_at,
                updated_at
                """)
            .eq("id", value: ids)
            .execute()
            .value
        
    }
    
    func fetchTeachingsWithLimit(collectionId: Int, from: Int, to: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                    id,
                    title,
                    description,
                    date,
                    image_id,
                    video_id,
                    created_at,
                    updated_at,
                    preacher: preacher_id (
                        id,
                        name,
                        preacher_role_id(id, name),
                        image_id,
                        created_at,
                        updated_at
                        )
                ),
                position,
                id,
                created_at,
                updated_at
                """) // El string con preach(...), preacher(...), etc.
            .eq("collection_id", value: collectionId)
            .order("updated_at", ascending: false) // <--- CRUCIAL: Lo último tocado sale primero
            .range(from: from, to: to)
            .execute()
            .value
    }
    
    func fetchAllPreachers() async throws -> [PreacherDTO] {
        try await supabaseClient
            .from("preacher")
            .select("""
                id,
                name,
                preacher_role_id(id, name),
                image_id,
                updated_at
                """)
            .execute()
            .value
    }
    func fetchCollectionTypes() async throws -> [CollectionTypeResponseDTO] {
        let data: [CollectionTypeResponseDTO] = try await supabaseClient
            .from("collection_type")
            .select("*")
            .execute()
            .value
        print(data)
        return data
    }
    
    func fetchSignedLink(for videoId: String) async throws -> VideoLinkResponseDTO {
        try await supabaseClient.functions.invoke(
            "get-vimeo-temporal-link",
            options: FunctionInvokeOptions(
                method: .post,
                body: ["videoId": videoId]
                //                body: ["videoId": "1234"]
            ))
    }
    func fetchSongs() async throws -> [SongDTO] {
        try await supabaseClient
            .from("song")
            .select("*")
            .execute()
            .value
    }
    
    func fetchPreach(id: Int) async throws -> PreachDTO {
        try await supabaseClient
            .from("preach")
            .select("*")
            .execute()
            .value
    }
    func fetchCollectionItem(id: Int) async throws -> CollectionItemResponseDTO {
        try await supabaseClient
            .from("collection_item")
            .select("""
                preach: preach_id (
                id,
                title,
                description,
                date,
                image_id,
                video_id,
                created_at,
                updated_at,
                preacher: preacher_id (
                    id,
                    name,
                    preacher_role_id(id, name),
                    image_id,
                    updated_at
                    )
                ),
                position,
                id,
                created_at,
                updated_at
                """)
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
}

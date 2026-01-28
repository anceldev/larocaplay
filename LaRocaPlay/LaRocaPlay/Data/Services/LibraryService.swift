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
    case preacher
}

final class LibraryService {
    private let supabaseClient = SupabaseClientInstance.shared.publicClient
    
    func fetchShortData<T:Decodable>(for table: SupabaseTable) async throws -> [T] {
        try await supabaseClient
            .from(table.rawValue)
            .select("id, updated_at")
            .execute()
            .value
    }
    
    func fetchCollections() async throws -> [CollectionDTO] {
        try await supabaseClient
            .from("collection")
            .select(Queries.collection.rawValue)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
    func fetchCollections(with ids: [Int]) async throws -> [CollectionDTO] {
        try await supabaseClient
            .from("collection")
            .select(Queries.collection.rawValue)
            .in("id", values: ids)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    func fetchCollection(id: Int) async throws -> CollectionDTO {
        try await supabaseClient
            .from("collection")
            .select(Queries.collection.rawValue)
            .eq("id", value: id)
            .single()
            .execute()
            .value
            
    }
    
    func fetchTeachings(collectionId: Int, limit: Int, offset: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select(Queries.collectionItem.rawValue)
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
            .select(Queries.shortCollectionItem.rawValue)
            .eq("collection_id", value: colId)
            .order("preach(date)", ascending: false)
            .range(from: 0, to: limit)
            .execute()
            .value
    }
    func fetchShortTeachingsWithoutLimit(collectionId: Int) async throws -> [ShortCollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select(Queries.shortCollectionItem.rawValue)
            .eq("collection_id", value: collectionId)
            .order("preach(date)", ascending: false)
            .execute()
            .value
    }
    
    func fetchTeachingsWithoutLimit(collectionId: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select(Queries.collectionItem.rawValue)
            .eq("collection_id", value: collectionId)
            .execute()
            .value
        
    }
    func fetchCollecitonItemsWithIds(for ids: [Int]) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select(Queries.collectionItem.rawValue)
            .in("id", values: ids)
            .execute()
            .value
        
    }
    
    func fetchTeachingsWithLimit(collectionId: Int, from: Int, to: Int) async throws -> [CollectionItemResponseDTO] {
        try await supabaseClient
            .from("collection_item")
            .select(Queries.collectionItem.rawValue)
            .eq("collection_id", value: collectionId)
            .order("updated_at", ascending: false) // <--- CRUCIAL: Lo último tocado sale primero
            .range(from: from, to: to)
            .execute()
            .value
    }
    
    func fetchAllPreachers() async throws -> [PreacherDTO] {
        try await supabaseClient
            .from("preacher")
            .select(Queries.preacher.rawValue)
            .execute()
            .value
    }
    
    func fetchPreachersWithIds(ids: [Int]) async throws -> [PreacherDTO] {
        try await supabaseClient
            .from("preacher")
            .select(Queries.preacher.rawValue)
            .in("id", values: ids)
            .execute()
            .value
    }
    
    func fetchCollectionTypes() async throws -> [CollectionTypeResponseDTO] {
        try await supabaseClient
            .from("collection_type")
            .select("*")
            .execute()
            .value
    }
    
    func fetchSignedLink(for videoId: String) async throws -> VideoLinkResponseDTO {
        try await supabaseClient.functions.invoke(
            "get-vimeo-temporal-link",
            options: FunctionInvokeOptions(
                method: .post,
                body: ["videoId": videoId]
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
            .select(Queries.collectionItem.rawValue)
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
}

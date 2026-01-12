//
//  LibraryManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import Foundation
import Observation
import SwiftData
import MediaPlayer
import Supabase
import os

@Observable
final class LibraryManager {
    private let service: LibraryService
    private let context: ModelContext
    
    var isFetching = false
    private let mainCollectionId: Int = 1
    private let logger = Logger(subsystem: "com.anceldev.LaRocaPlay", category: "LibraryManager")
    
    init(service: LibraryService, context: ModelContext) {
        self.service = service
        self.context = context
    }
    
    @MainActor
    func initialSync() async {
        self.isFetching = true
        defer { self.isFetching = false }
        do {
            let preachersDTOs = try await service.fetchAllPreachers()
            //            preachersDTOs.forEach { context.insert($0.toModel()) }
            try await syncPreachers(dtos: preachersDTOs)
            
            let collectionTypesDTOS = try await service.fetchCollectionTypes()
            collectionTypesDTOS.forEach { context.insert($0.toModel()) }
            
            let collectionDTOs = try await service.fetchCollections()
            try await syncCollections(dtos: collectionDTOs)
            
            let preachesDTOs = try await service.fetchTeachings(collectionId: mainCollectionId, limit: 5, offset: 0)
            try syncPreaches(dtos: preachesDTOs, into: mainCollectionId)
        } catch let error as PostgrestError {
            print("ERROR: Error de postgrest: \(error.localizedDescription)")
        } catch {
            print(error)
            print("ERROR: Error en carga inicial \(error.localizedDescription)")
            
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                print("DEBUG: La petición fue cancelada intencionadamente.")
            } else {
                print("ERROR real: \(error)")
            }
            
        }
    }
    @MainActor
    func syncPreachers(dtos: [PreacherDTO]) async throws {
        guard NetworkMonitor.shared.isConnected else {
            print("")
            return
        }
        //        let allIds = dtos.map { $0.id }
        let localPreachers = try context.fetch(FetchDescriptor<Preacher>())
        
        let preachersDictionary: [Int: Preacher] = Dictionary(uniqueKeysWithValues: localPreachers.map({ ($0.id, $0 )}))
        for dto in dtos {
            if let existing = preachersDictionary[dto.id] {
                //                if let serverDate  = dto.updatedAt,
                //                   let localDate = existing.updatedAt,
                //                   serverDate > localDate {
                if dto.updatedAt > existing.updatedAt {
                    existing.update(from: dto)
                }
                //                } else {
                //                    let newPreacher = dto.toModel()
                //                    context.insert(newPreacher)
                //                }
            } else {
                let newPreacher = dto.toModel()
                context.insert(newPreacher)
            }
        }
        if context.hasChanges{ try context.save() }
    }
    
    
    @MainActor
    func syncCollections(dtos: [CollectionDTO]) async throws {
        let allIds = dtos.map { $0.id }
        let descriptor = FetchDescriptor<Collection>()
        let localCollections = try context.fetch(descriptor)
        
        // Borrado de colecciones que no están en el server
        let serverIds = Set(allIds)
        var activeCollectionsDict: [Int : Collection] = [:]
        
        for localCollection in localCollections {
            if !serverIds.contains(localCollection.id) {
                context.delete(localCollection)
            } else {
                activeCollectionsDict[localCollection.id] = localCollection
            }
        }
        
        for dto in dtos {
            if let existing = activeCollectionsDict[dto.id] {
                //                if let serverDate = dto.updatedAt,
                //                   let localDate = existing.updatedAt,
                //                   serverDate > localDate {
                if dto.updatedAt > existing.updatedAt {
                    existing.update(from: dto)
                    existing.needItemsSync = true
                }
            } else {
                let newCollection = dto.toModel()
                newCollection.needItemsSync = true
                context.insert(newCollection)
            }
        }
        if context.hasChanges { try context.save() }
    }
    
    
    
    @MainActor
    private func syncPreaches(dtos: [CollectionItemResponseDTO], into collectionId: Int) throws {
        for preach in dtos {
            print(preach.preach.date)
        }
        if dtos.isEmpty { return }
        let preacherDescriptor = FetchDescriptor<Preacher>()
        let allPreachers = try context.fetch(preacherDescriptor)
        let preachersDict = Dictionary(uniqueKeysWithValues: allPreachers.map({ ($0.id, $0) }))
        
        let collectionDescriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == collectionId })
        let collection = try context.fetch(collectionDescriptor).first
        
        print(collection)
        
        guard let collection, !preachersDict.isEmpty else {
            print("DEBUG: No hay preachers o colección todavia")
            return
        }
        
        let incomingPreachIds = dtos.map { $0.preach.id }
        let incomingLinkIds = dtos.map { $0.id }
        let serverLinkIds = Set(incomingLinkIds)
        
        let existingPreaches = try context.fetch(
            FetchDescriptor<Preach>(
                predicate: #Predicate<Preach>{ incomingPreachIds.contains($0.id)
                },
                sortBy: [SortDescriptor(\.date, order: .reverse )])
        )
        
        
        let preachesDict = Dictionary(uniqueKeysWithValues: existingPreaches.map({ ($0.id, $0) }))
        
        var activeLinksDict: [Int : CollectionItem] = [:]
        
        for localItem in collection.items {
            if !serverLinkIds.contains(localItem.id) {
                context.delete(localItem)
            } else {
                activeLinksDict[localItem.id] = localItem
            }
        }
        
        for dto in dtos {
            let targetPreach: Preach
            if let localPreach = preachesDict[dto.preach.id] {
                //                if let remoteDate = dto.preach.updatedAt,
                //                   let localDate = localPreach.updatedAt,
                //                   remoteDate > localDate {
                if dto.preach.updatedAt > localPreach.updatedAt {
                    localPreach.update(from: dto.preach)
                }
                targetPreach = localPreach
            } else {
                targetPreach = dto.preach.toModel()
                context.insert(targetPreach)
            }
            
            targetPreach.preacher = preachersDict[dto.preach.preacher.id]
            
            
            // MAnejo de links
            if let link = activeLinksDict[dto.id] {
                link.position = dto.position ?? 0
                link.preach = targetPreach
            } else {
                let newLink = CollectionItem(id: dto.id, position: dto.position ?? 0)
                newLink.collection = collection
                newLink.preach = targetPreach
                context.insert(newLink)
            }
        }
        if context.hasChanges { try context.save() }
    }
    
    @MainActor
    func getValidVideoUrl(for preach: Preach) async throws -> URL {
        if preach.hasValidUrl, let url = preach.videoUrl {
            logger.info("DEBUG: Usando URL local")
            return URL(string: url)!
        }
        do {
            let response = try await service.fetchSignedLink(for: preach.videoId)
            
            preach.updateVideoCache(
                url: response.videoUrl,
                expiration: response.linkExpirationTime
            )
            try context.save()
            return URL(string: response.videoUrl)!
        } catch let error as Supabase.FunctionsError {
            try handleVimeoEdgeError(error)
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw VimeoUIError.noInternet
            }
            throw VimeoUIError.serverError("Error de red")
        } catch {
            throw VimeoUIError.unexpectedResponse
        }
    }
    
    @MainActor
    func syncCollectionItems(for collection: Collection) async throws {
        guard collection.needItemsSync else { return }
        let targetID = collection.id
        let itemDTOs = try await service.fetchTeachingsWithoutLimit(collectionId: targetID)
        try syncPreaches(dtos: itemDTOs, into: targetID)
        collection.needItemsSync = false
        try context.save()
    }
    
    @MainActor
    func loadSongs() async {
        self.isFetching = true
        defer { self.isFetching = false }
        do {
            let dtos = try await service.fetchSongs()
            try await syncSongs(dtos: dtos)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func syncSongs(dtos: [SongDTO]) async throws {
            for dto in dtos {
                let song = dto.toModel()
                context.insert(song)
            }
            try context.save()
    }
}

extension LibraryManager {
    func updateNowPlayingInfo(for preach: Preach, duration: Double = 0) {
        let center = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = preach.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = preach.preacher?.name ?? "Predicador"
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        center.nowPlayingInfo = nowPlayingInfo
    }
    
    private func handleVimeoEdgeError(_ error: FunctionsError) throws -> Never {
        // 1. Intentar decodificar nuestro JSON con 'code'
        if let data = error.localizedDescription.data(using: .utf8),
           let errorBody = try? JSONDecoder().decode(EdgeFunctionErrorBody.self, from: data) {
            
            switch errorBody.code {
            case .videoNotFound: throw VimeoUIError.videoNotFound
            case .timeout: throw VimeoUIError.vimeoTimeout
            case .videoProcessing: throw VimeoUIError.processingVideo
            case .configError: throw VimeoUIError.configurationError
            default: throw VimeoUIError.serverError(errorBody.error)
            }
        }
        
        // 2. Si no es nuestro JSON, pero hay un mensaje de texto
        throw VimeoUIError.serverError("Error del servidor: \(error.localizedDescription)")
    }
}

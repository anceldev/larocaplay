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

@Observable
final class LibraryManager {
    private let service: LibraryService
    private let context: ModelContext
    
    var isFetching = false
    private let mainCollectionId: Int = 1
    
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
            preachersDTOs.forEach { context.insert($0.toModel()) }
            
            let collectionTypesDTOS = try await service.fetchCollectionTypes()
            collectionTypesDTOS.forEach { context.insert($0.toModel()) }
            
            
            let collectionDTOs = try await service.fetchCollections()
//            collectionDTOs.forEach { context.insert($0.toModel()) }
//            try context.save()
            try await syncCollections(dtos: collectionDTOs)

            let preachesDTOs = try await service.fetchTeachings(collectionId: mainCollectionId, limit: 5, offset: 0)
            try syncPreaches(dtos: preachesDTOs, into: mainCollectionId)
            
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
                if let serverDate = dto.updatedAt,
                   let localDate = existing.updatedAt,
                   serverDate > localDate {
                    existing.update(from: dto)
                    existing.needItemsSync = true
                }
            } else {
                let newCollection = dto.toModel()
                newCollection.needItemsSync = true
                context.insert(newCollection)
            }
        }
        if context.hasChanges {
            try context.save()
        }
    }
    

    
    @MainActor
    private func syncPreaches(dtos: [CollectionItemResponseDTO], into collectionId: Int) throws {
        let preacherDescriptor = FetchDescriptor<Preacher>()
        let allPreachers = try context.fetch(preacherDescriptor)
        let preachersDict = Dictionary(uniqueKeysWithValues: allPreachers.map({ ($0.id, $0) }))
        
        let collectionDescriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == collectionId })
        let collection = try context.fetch(collectionDescriptor).first
        
        guard let collection, !preachersDict.isEmpty else {
            print("DEBUG: No hay preachers o colección todavia")
            return
        }
        
        let incomingPreachIds = dtos.map { $0.preach.id }
        let incomingLinkIds = dtos.map { $0.id }
        let serverLinkIds = Set(incomingLinkIds)
        
        let existingPreaches = try context.fetch(FetchDescriptor<Preach>(predicate: #Predicate<Preach>{ incomingPreachIds.contains($0.id) }))
        
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
                if let remoteDate = dto.preach.updatedAt,
                   let localDate = localPreach.updatedAt,
                   remoteDate > localDate {
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
        if context.hasChanges {
            try context.save()
        }
    }
    
//    @MainActor
//    func syncSpecificCollection(id: Int) async {
//        do {
//            let dtos = try await service.fetchTeachings(collectionId: id, limit: 20, offset: 0)
//            try syncPreaches(dtos: dtos, into: id)
//        } catch {
//            print("ERROR: Error en sync collection \(error)")
//        }
//    }
    
    @MainActor
    func getValidVideoUrl(for preach: Preach) async throws -> URL {
        if preach.hasValidUrl, let url = preach.videoUrl {
            print("DEBUG: Usando URL cacheada para: \(preach.title)")
            return URL(string: url)!
        }
        let response = try await service.fetchSignedLink(for: preach.videoId)
        
        preach.updateVideoCache(
            url: response.videoUrl,
            expiration: response.linkExpirationTime
        )
        try context.save()
        return URL(string: response.videoUrl)!
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
}

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
    
//    func setContext(context: ModelContext) {
//        self.modelContext = modelContext
//    }
    
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
            collectionDTOs.forEach { context.insert($0.toModel()) }
            try context.save()

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
    func syncCollections(dtos: [CollectionDTO]) throws {
        let ids = dtos.map { $0.id }
        let descriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ ids.contains($0.id) })
        let existingCollections = try context.fetch(descriptor)
    }
    

    
    @MainActor
    private func syncPreaches(dtos: [CollectionPreachResponseDTO], into collectionId: Int) throws {
        let preacherDescriptor = FetchDescriptor<Preacher>()
        let preachers = try context.fetch(preacherDescriptor)
        
        let collectionDescriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == collectionId })
        let collection = try? context.fetch(collectionDescriptor).first
        
        guard let collection, !preachers.isEmpty else {
            print("DEBUG: No hay preachers o colección todavia")
            return
        }
        for dto in dtos {
            
            let preachId = dto.preach.id
            let preachDescriptor = FetchDescriptor<Preach>(predicate: #Predicate<Preach>{ $0.id == preachId })
            let existingPreach = try? context.fetch(preachDescriptor).first
            
            let targetPreach: Preach
            if let localPreach = existingPreach {
                if let remoteDate = dto.preach.updatedAt,
                    let localDate = localPreach.updatedAt,
                    remoteDate > localDate {
                    print("DEBUG: Actualizando contenido de predica")
                    localPreach.update(from: dto.preach)
                }
                targetPreach = localPreach
            } else {
                print("DEBUG: Insertando nueva predica")
                let newPreach = dto.preach.toModel()
                context.insert(newPreach)
                targetPreach = newPreach
            }
            targetPreach.preacher = preachers.first(where: { $0.id == dto.preach.preacher.id })
        
            
            let linkId = dto.id
            let descriptor = FetchDescriptor<CollectionItem>(predicate: #Predicate<CollectionItem>{ $0.id == linkId })
            let existingLink = try? context.fetch(descriptor).first
            
            if let link = existingLink {
                link.position = dto.position ?? 0
                link.preach = targetPreach
            } else {
                let newLink = CollectionItem(id: linkId, position: dto.position ?? 0)
                newLink.collection = collection
                newLink.preach = targetPreach
                context.insert(newLink)
            }
        }
        try context.save()
    }
    
    @MainActor
    func syncSpecificCollection(id: Int) async {
        do {
            let dtos = try await service.fetchTeachings(collectionId: id, limit: 20, offset: 0)
            try syncPreaches(dtos: dtos, into: id)
        } catch {
            print("ERROR: Error en sync collection \(error)")
        }
    }
    
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

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

enum LibManagerError: Error, LocalizedError {
    case noCollectionItemFound(String)
}

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
            try await syncPreachers(dtos: preachersDTOs)
            
            let collectionTypesDTOS = try await service.fetchCollectionTypes()
            collectionTypesDTOS.forEach { context.insert($0.toModel()) }
            
            let collectionDTOs = try await service.fetchCollections()
            try await syncCollections(dtos: collectionDTOs)
            
            // Fetch de el último item de main collection
            let preachesDTOs = try await service.fetchTeachings(collectionId: Constants.mainCollectionId, limit: 1, offset: 0)
            _ = try syncPreaches(dtos: preachesDTOs, into: Constants.mainCollectionId)
        } catch let error as PostgrestError {
            //            print("ERROR: Error de postgrest: \(error.localizedDescription)")
            logger.error("ERROR: Error de postgrest: \(error)")
        } catch {
            //            print(error)
            //            print("ERROR: Error en carga inicial \(error.localizedDescription)")
            logger.error("ERROR: Error de postgrest: \(error)")
            
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                //                print("DEBUG: La petición fue cancelada intencionadamente.")
                logger.debug("DEBUG: La petición fue cancelada intencionadamente")
            } else {
                //                print("ERROR real: \(error)")
                logger.error("ERROR real: \(error)")
            }
            
        }
    }
    
    @MainActor
    func refreshInitialSync() async {
        do {
            let collectionDTOs = try await service.fetchCollections()
            try await syncCollections(dtos: collectionDTOs)
            let preachesDTOs = try await service.fetchTeachings(collectionId: Constants.mainCollectionId, limit: 1, offset: 0)
            _ = try syncPreaches(dtos: preachesDTOs, into: Constants.mainCollectionId)
        } catch let error as PostgrestError {
            logger.error("ERROR: Error de postgrest: \(error)")
        } catch {
            logger.error("ERROR: Error de postgrest: \(error)")
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                logger.debug("DEBUG: La petición fue cancelada intencionadamente")
            } else {
                logger.error("ERROR real: \(error)")
            }
            
        }
    }
    
    @MainActor
    func syncPreachers(dtos: [PreacherDTO]) async throws {
        guard NetworkMonitor.shared.isConnected else {
            logger.info("No hay conexión de internet")
            return
        }
        let localPreachers = try context.fetch(FetchDescriptor<Preacher>())
        
        let preachersDictionary: [Int: Preacher] = Dictionary(uniqueKeysWithValues: localPreachers.map({ ($0.id, $0 )}))
        for dto in dtos {
            if let existing = preachersDictionary[dto.id] {
                if dto.updatedAt > existing.updatedAt {
                    existing.update(from: dto)
                }
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
        if dtos.isEmpty { return }
        let preacherDescriptor = FetchDescriptor<Preacher>()
        let allPreachers = try context.fetch(preacherDescriptor)
        let preachersDict = Dictionary(uniqueKeysWithValues: allPreachers.map({ ($0.id, $0) })) // Obtengo los preachers
        
        var collectionDescriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == collectionId })
        collectionDescriptor.fetchLimit = 1
        let collection = try context.fetch(collectionDescriptor).first // Obtengo la colección
        
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
        
        let preachesDict = Dictionary(uniqueKeysWithValues: existingPreaches.map({ ($0.id, $0) })) // Existing preaches
        
        var activeLinksDict: [Int : CollectionItem] = [:] // Diccionario de links activos.
        
        // Elimino links que ya no están en db
        for localItem in collection.items {
            if !serverLinkIds.contains(localItem.id) {
                context.delete(localItem)
            } else {
                activeLinksDict[localItem.id] = localItem
            }
        }
        
        for dto in dtos {
            let targetPreach: Preach
            if let localPreach = preachesDict[dto.preach.id] { // Si hay preach en local compruebo el updated at (y actualizo si hace falta). Si no inserto el nuevo preach
                if dto.preach.updatedAt > localPreach.updatedAt {
                    localPreach.update(from: dto.preach)
                }
                targetPreach = localPreach
            } else {
                targetPreach = dto.preach.toModel()
                context.insert(targetPreach)
            }
            
            targetPreach.preacher = preachersDict[dto.preach.preacher.id] // Actualizo el preacher de la preach que acabo de comprobar/añadir
            
            // MAnejo de links. Si sigue activo actualizo posición y preach
            if let link = activeLinksDict[dto.id] {
                link.position = dto.position ?? 0
                link.preach = targetPreach
            } else { // Si es nuevo lo añado
                let newLink = CollectionItem(
                    id: dto.id,
                    position: dto.position ?? 0,
                    createdAt: dto.createdAt,
                    updatedAt: dto.updatedAt
                )
                newLink.collection = collection
                newLink.preach = targetPreach
                context.insert(newLink)
            }
        }
        if context.hasChanges { try context.save() }
    }
    
    @MainActor
    func getValidVideoUrl(for preach: Preach) async throws -> URL {
        if preach.videoId.count > 1, preach.hasValidUrl, let url = preach.videoUrl {
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
            logger.error("Error en Vimeo Edge Function \(error)")
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
        //        let itemsDescriptos = FetchDescriptor<CollectionItem>(predicate: #Predicate<CollectionItem>{ $0.collection?.id == targetID})
        collection.needItemsSync = false
        try context.save()
    }
    
    @MainActor
    func syncMainCollectionItems(for mainCollection: Collection) async throws {
        let collectionId = 1
        let itemDTOs = try await service.fetchTeachings(collectionId: collectionId, limit: 5, offset: 0)
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
    
    @MainActor
    //    func getCollectionItem(id: Int, isDeepLink: Bool) async throws -> Preach {
    func getCollectionItem(itemId: Int, isDeepLink: Bool) async throws -> CollectionItem {
        let targetID = itemId
        if isDeepLink {
            let item = try await fetchAndSyncCollectionItem(itemId: targetID)
            guard item.preach != nil, item.collection != nil else {
                throw LibManagerError.noCollectionItemFound("No se encontro el item en la base de datos")
            }
            return item
        }
        let descriptor = FetchDescriptor<CollectionItem>(predicate: #Predicate<CollectionItem>{ $0.id == targetID })
        if let local = try? context.fetch(descriptor).first {
            guard local.preach != nil, local.collection != nil else {
                throw LibManagerError.noCollectionItemFound("No se encontro el item en la memoria caché")
            }
            // Si hay local lo devuelvo pero intento ver si está actualizado
            Task {
                do {
                    _ = try await fetchAndSyncCollectionItem(itemId: targetID)
                } catch {
                    logger.error("Fallo el refreso en segundo plano: \(error)")
                }
            }
            return local
        }
        
        let item = try await fetchAndSyncCollectionItem(itemId: itemId)
        guard item.preach != nil, item.collection != nil else {
            throw LibManagerError.noCollectionItemFound("No se encontro el item de la base de datos")
        }
        return item
    }
    
    @MainActor
    func refreshCollectinoItem(itemId: Int) async throws -> CollectionItem {
        let item = try await fetchAndSyncCollectionItem(itemId: itemId)
        guard item.preach != nil, item.collection != nil else {
            throw LibManagerError.noCollectionItemFound("No se encontró el item en la base de datos")
        }
        return item
    }
    
    
    private func fetchAndSyncCollectionItem(itemId: Int) async throws -> CollectionItem {
        let dto = try await service.fetchCollectionItem(id: itemId)
        let descriptor = FetchDescriptor<CollectionItem>(predicate: #Predicate<CollectionItem>{$0.id == itemId })
        let existing = try? context.fetch(descriptor).first
        
        if let existing {
            if dto.updatedAt > existing.updatedAt {
                existing.update(from: dto)
                try context.save()
            }
            return existing
        } else {
            let new = dto.toModel()
            context.insert(new)
            try context.save()
            return new
        }
    }
    
    @MainActor
    func getCollection(id: Int, isDeepLink: Bool) async throws -> Collection {
        let targetID = id
        
        // Si viene por una notificacion o un enlace compartido.
        if isDeepLink {
            let collection = try await fetchAndSyncColllectionFromSupabase(collectionId: targetID)
            try await syncCollectionItems(for: collection)
            return collection
        }
        var descriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == targetID })
        descriptor.fetchLimit = 1
        let local = try? context.fetch(descriptor).first
        
        if let local {
            try await syncCollectionItems(for: local)
            return local
        }
        let collection = try await fetchAndSyncColllectionFromSupabase(collectionId: targetID)
        try await syncCollectionItems(for: collection)
        return collection
    }
    
    @MainActor
    func refreshCollection(id: Int) async throws -> Collection {
        let collection = try await fetchAndSyncColllectionFromSupabase(collectionId: id)
        try await syncCollectionItems(for: collection)
        return collection
    }
    
    private func fetchAndSyncColllectionFromSupabase(collectionId: Int) async throws -> Collection {
        do {
            let dto = try await service.fetchCollection(id: collectionId)
            let descriptor = FetchDescriptor<Collection>(predicate: #Predicate<Collection>{ $0.id == collectionId })
            let existing = try? context.fetch(descriptor).first
            
            if let existing {
                if dto.updatedAt > existing.updatedAt {
                    existing.update(from: dto)
                    existing.needItemsSync = true
                    try context.save()
                }
                return existing
            } else {
                let new = dto.toModel()
                new.needItemsSync = true
                context.insert(new)
                try context.save()
                return new
            }
        } catch {
            logger.error("ERROR: \(error)")
            logger.error("ERROR: \(error.localizedDescription)")
            throw error
        }
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

//
//  SwiftUIView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import Foundation
import Observation
import Appwrite
import JSONCodable

enum AWCongig: String {
    case projectId = "688433c6002933c015b2"
    case endpoint = "https://fra.cloud.appwrite.io/v1"
    case db = "688a4d1100336fad37f2"
    case bucket = "688ce98a001196a32902"
}

enum AWCollections: String {
    case preaches = "688ce0f80016c6036fa6"
}

final class AWClient {
    let client: Appwrite.Client
    let database: Databases
    let storage: Appwrite.Storage
    
    private init() {
        self.client = Appwrite.Client()
            .setEndpoint(AWCongig.endpoint.rawValue)
            .setProject(AWCongig.projectId.rawValue)
        self.database = Databases(client)
        self.storage = Appwrite.Storage(client)
    }
}
extension AWClient {
    static var shared: AWClient = .init()
}


@Observable
final class AWService {
    
    let database = AWClient.shared.database
    
    func getPreaches() async throws -> [PreachDTO] {
        do {
            let docs = try await database.listDocuments(
                databaseId: AWCongig.db.rawValue,
                collectionId: AWCollections.preaches.rawValue,
                queries: [
                    Query.orderDesc("date")
                ]
            )
            print(docs)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let documentList: [PreachDTO] = try docs.documents.compactMap { doc in
//                let documentData = try convertToData(doc.data)
                let dict = doc.data.mapValues { $0.value }
                let documentData = try JSONSerialization.data(withJSONObject: dict)
            
                let model = try decoder.decode(PreachDTO.self, from: documentData)
                return model
            }
            return documentList
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
        
    }
}
func convertToData(_ anyCodableDict: [String:AnyCodable]) throws -> Data {
    let jsonCompatibleDict = anyCodableDict.mapValues { $0.value }
    return try JSONSerialization.data(withJSONObject: jsonCompatibleDict)
}

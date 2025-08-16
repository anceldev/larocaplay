//
//  APIKeysManager.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 10/8/25.
//

import Foundation

class APIKeysManager {
    static let shared = APIKeysManager()
    
    private let baseURL = "https://keys-backend-gamma.vercel.app"
    private let session = URLSession.shared
    private var cachedKeys: [String: CachedKey] = [:]
    
    
    private struct CachedKey {
        let key: String
        let timestamp: Date
        let ttl: TimeInterval = 3600
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    func getAPIKey(for service: String) async throws -> String {
        if let cached = cachedKeys[service], !cached.isExpired {
            return cached.key
        }
        
        guard let url = URL(string: "\(baseURL)/api/keys/\(service)") else {
            throw KeyError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let bundleId = Bundle.main.bundleIdentifier {
            print(bundleId)
            request.setValue(bundleId, forHTTPHeaderField: "x-bundle-id")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw KeyError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw KeyError.serverError(httpResponse.statusCode)
            }
            let keyResponse = try JSONDecoder().decode(KeyResponse.self, from: data)
            cachedKeys[service] = CachedKey(key: keyResponse.key, timestamp: Date())
            return keyResponse.key
        } catch {
            print(error.localizedDescription)
            throw KeyError.networkError(error)
        }
    }
    
    func clearCache() {
        cachedKeys.removeAll()
    }
    func clearExpiredCache() {
        cachedKeys = cachedKeys.filter { !$0.value.isExpired}
    }
}

private struct KeyResponse: Codable {
    let key: String
    let service: String
}

enum KeyError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalida"
        case .invalidResponse:
            return "Respuesta invalida del servidor"
        case .serverError(let code):
            return "Error del servidor: \(code)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        }
    }
}

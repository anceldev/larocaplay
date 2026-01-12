//
//  EdgeFunctionErrorBody.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 11/1/26.
//

import Foundation

struct EdgeFunctionErrorBody: Decodable {
    let error: String
    let code: EdgeFunctionVimeoErrorCode
    let success: Bool
}

enum EdgeFunctionVimeoErrorCode: String, Decodable {
    case missingId = "MISSING_VIDEO_ID"
    case configError = "CONFIG_ERROR"
    case vimeoApiError = "VIMEO_API_ERROR"
    case videoNotFound = "VIDEO_NOT_FOUND"
    case videoProcessing = "VIDEO_PROCESSING"
    case timeout = "TIMEOUT"
    case internalError = "INTERNAL_ERROR"
    case unknown = "UNKNOWN"
}
enum VimeoUIError: Error, LocalizedError {
    case noInternet
    case videoNotFound
    case vimeoTimeout
    case processingVideo
    case configurationError
    case serverError(String)
    case unexpectedResponse
    
    var errorDescription: String? {
        switch self {
        case .noInternet: return "Comprueba tu conexión a internet."
        case .videoNotFound: return "El video no existe o ha sido eliminado."
        case .vimeoTimeout: return "Vimeo tardó demasiado. Inténtalo de nuevo."
        case .processingVideo: return "El video se está procesando. Reintenta en un poco más tarde."
        case .configurationError: return "Error de configuración en el servidor."
        case .serverError(let msg): return msg
        case .unexpectedResponse: return "Recibimos una respuesta inesperada del servidor."
        }
    }
}

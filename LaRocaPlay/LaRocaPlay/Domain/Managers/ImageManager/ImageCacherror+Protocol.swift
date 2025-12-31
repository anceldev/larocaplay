//
//  ImageCacherror+Protocol.swift
//  Movix
//
//  Created by Ancel Dev account on 7/2/25.
//

import Foundation
import SwiftUI

enum ImageCacheError: Error {
    case invalidImage
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case directoryCreationFailed
    case cacheDirectoryNotFound
    case compressionFailed
    case invalidFileURL
    case downloadFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "La imagen no es válida"
        case .saveFailed(let reason):
            return "Error al guardar la imagen: \(reason)"
        case .loadFailed(let reason):
            return "Error al cargar la imagen: \(reason)"
        case .deleteFailed(let reason):
            return "Error al eliminar la imagen: \(reason)"
        case .directoryCreationFailed:
            return "No se pudo crear el directorio de caché"
        case .cacheDirectoryNotFound:
            return "No se encontró el directorio de caché"
        case .compressionFailed:
            return "Error al comprimir la imagen"
        case .invalidFileURL:
            return "URL de archivo inválida"
        case .downloadFailed:
            return "Error al descargar la imagen"
        }
    }
}

protocol ImageCacheProtocol {
    func getImage(forKey key: String) async throws -> UIImage?
    func saveImage(_ image: UIImage, forKey key: String) async throws
    func removeImage(forKey key: String) async throws
    func clearCache() async throws
}

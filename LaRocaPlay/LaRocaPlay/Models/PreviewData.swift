//
//  PreviewData.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import Foundation


class PreviewData {
    static let user: User = .init(id: UUID(), name: "Test User", email: "test@mail.com", role: .admin)
    
    static let preacherMiguel: PreacherDTO = .init(id: 1, name: "Miguel López", role: .init(id: 1, name: "Pastor"), thumbId: nil)
    static let preacherJavier: PreacherDTO = .init(id: 2, name: "Javier Felipe", role: .init(id: 1, name: "Pastor"), thumbId: nil)
    static let preacherYuna: PreacherDTO = .init(id: 3, name: "Yuna Lee", role: .init(id: 2, name: "Pastora"), thumbId: nil)
    static let preachers: [PreacherDTO] = [
        PreviewData.preacherMiguel,
        PreviewData.preacherJavier,
        PreviewData.preacherYuna
    ]
    
    static let preachCollectionTypes: [PreachCollectionType] = [
        .init(id: 1, name: "Colección"),
        .init(id: 2, name: "Serie"),
        .init(id: 3, name: "Discipulado 1"),
        .init(id: 4, name: "Congreso"),
        .init(id: 5, name: "Otro")
    ]
    
    static let preachCollections: [PreachCollection] = [

        .init(
            id: 1,
            title: "Honra y recompensa",
            description: "Serie de honra y recompensa impartida por nuestra Pastora Rosa",
            isPublic: true,
            collectionType: PreviewData.preachCollectionTypes[2],
            createdAt: .now,
            updatedAt: nil,
            endedAt: nil
        )
        ]
    
    static let preaches: [PreachDTO] = [
//        .init(
//            id: 1,
//            title: "Honra a todos",
//            description: "Este domingo nuestro pastor Miguel impartió el tema: Honra a todos, de la serie Honra y recompensa.",
//            date: .now,
//            preacher: PreviewData.preacherMiguel,
//            video: "https://vimeo.com/1107196095/de39f75d2d",
//            
//            
//            serie: PreviewData.serie,
//            thumbId: nil,
//            congress: nil
//        ),
//        .init(
//            id: 2,
//            title: "Honra a los civiles",
//            description: "Este domingo nuestro pastor Javier impartió el tema: Honra a los líderes civiles, de la serie Honra y recompensa.",
//            date: .now,
//            preacher: PreviewData.preacherJavier,
//            video: "No video available",
//            serie: PreviewData.serie,
//            thumbId: nil,
//            congress: nil
//        ),
//        .init(
//            id: 3,
//            title: "Valladolid, ciudad de avivamiento",
//            description: "Este domingo nuestra pastora Yuna impartió el tema: Valladolid, ciudad de avivamiento.",
//            date: .now,
//            preacher: PreviewData.preacherYuna,
//            video: "No video available",
//            serie: nil,
//            thumbId: nil,
//            congress: nil
//        ),
//        .init(
//            id: 4,
//            title: "Relaciones que impulsan",
//            description: "Este domingo nuestro pastor Javier impartió el tema: Relaciones que impulsan.",
//            date: .now,
//            preacher: PreviewData.preacherJavier,
//            video: "No video available",
//            serie: nil,
//            thumbId: nil,
//            congress: nil
//        )
    ]
}

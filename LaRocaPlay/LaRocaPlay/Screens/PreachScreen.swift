//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI

enum FetchFlow {
    case loading
    case completed
    case notFound
    case error
}

struct PreachScreen: View {
    var id: String
    @State private var fetchFlow: FetchFlow = .loading
    @State private var preach: Preach?
    var body: some View {
        VStack {
            Group {
                switch fetchFlow {
                case .loading:
                    Text("Cargando")
                case .completed:
                    PreachView(preach: preach!)
                case .notFound:
                    Text("No se pudo encontrar la predica")
                case .error:
                    Text("Ha habido un error al intentar obtener la predica seleccionado, por favor vuelve a intentarlo")
                }
            }
        }
        .onAppear {
            preach = fetchPreach()
        }
    }
    private func fetchPreach() -> Preach? {
        // Primero compruebo que ya se haya hecho fetch de esa predica
        return nil
    }
}

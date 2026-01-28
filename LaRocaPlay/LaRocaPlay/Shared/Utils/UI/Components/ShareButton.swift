//
//  ShareButton.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import SwiftUI

struct ShareButton: View {
    let videoID: String
    let titulo: String

    var body: some View {
        Button(action: shareVideo) {
            Label("Compartir", systemImage: "square.and.arrow.up")
        }
    }

    func shareVideo() {
        // Tu dominio configurado para Universal Links
        let url = URL(string: "https://tuiglesia.com/video/\(videoID)")!
        let mensaje = "Mira esta enseñanza: \(titulo)"
        
        let activityVC = UIActivityViewController(activityItems: [mensaje, url], applicationActivities: nil)
        // Presentar el controlador (necesita acceso al Root ViewController)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(activityVC, animated: true)
        }
    }
}

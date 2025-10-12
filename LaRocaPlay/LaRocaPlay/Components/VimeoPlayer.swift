//
//  VimeoPlayer.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI
import WebKit
import UIKit


struct VimeoPlayer: UIViewRepresentable {
    let videoURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Configuración adicional para mejor experiencia
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: videoURL) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct VimeoEmbedPlayer: UIViewRepresentable {
    let embedHTML: String
    init(videoURL: String) {
        self.embedHTML = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { margin: 0; padding: 0; background: black; }
            iframe { width: 100%; height: 100vh; border: none; }
        </style>
    </head>
    <body>
        <iframe src="\(videoURL)?badge=0&autopause=0&player_id=0&app_id=58479" 
                width="100%" 
                height="100%" 
                frameborder="0" 
                allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" 
                referrerpolicy="strict-origin-when-cross-origin" 
                title="Honra y recompensa 12 - pastor Miguel 03.08.2025">
        </iframe>
    </body>
    </html>
    """
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

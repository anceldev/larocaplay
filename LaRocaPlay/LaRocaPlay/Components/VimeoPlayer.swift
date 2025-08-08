//
//  VimeoPlayer.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI
import WebKit
import UIKit


struct VimeoPlayerView: UIViewRepresentable {
//    let videoID: String
//    let hash: String? // For private videos
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
//        let urlString: String
//        if let hash = hash {
//            urlString = "https://player.vimeo.com/video/\(videoID)?h=\(hash)"
//        } else {
//            urlString = "https://player.vimeo.com/video/\(videoID)"
//        }
        
//        if let url = URL(string: urlString) {
        print(url)
            let request = URLRequest(url: url)
            webView.load(request)
//        }
    }
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        let urlString: String
//        if let hash = hash {
//            urlString = "https://player.vimeo.com/video/\(videoID)?h=\(hash)"
//        } else {
//            urlString = "https://player.vimeo.com/video/\(videoID)"
//        }
//        
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Vimeo player loaded")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed to load Vimeo player: \(error)")
        }
    }
}

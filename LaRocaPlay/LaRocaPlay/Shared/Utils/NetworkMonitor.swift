//
//  NetworkMonitor.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/1/26.
//

import Network
import Observation
import Foundation
import Combine

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                print("Red: \(path.status == .satisfied ? "Conectado" : "Desconectado")")
            }
        }
        monitor.start(queue: queue)
    }
}

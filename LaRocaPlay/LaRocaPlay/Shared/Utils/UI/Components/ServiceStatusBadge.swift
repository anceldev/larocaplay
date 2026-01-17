//
//  SwiftUIView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/1/26.
//

import SwiftUI


struct ServiceStatusBadge: View {
    
    @State private var serviceStatus: ServiceStatus = .offline
    
    var label: String {
        switch serviceStatus {
        case .healthy: ""
        case .offline: "Sin internet"
        case .serverMaintenance: "Mantenimiento"
        case .storeMaintenance: "Tienda no disponible"
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.white.opacity(0.2))
            .background(.white)
            .mask(RoundedRectangle(cornerRadius: 50))
            .shadow(color: .yellow.opacity(0.8), radius: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
    }
}

#Preview {
    ServiceStatusBadge()
}

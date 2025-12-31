//
//  CustomDialog.swift
//  Movix
//
//  Created by Ancel Dev account on 14/3/25.
//

import SwiftUI

enum DialogType {
    case changeLanguage
    case changeCountry
    
    var title: String {
        switch self {
        case .changeLanguage:
            "Cambiar idioma"
        case .changeCountry:
            "Cambiar país"
        }
    }
    
    var confirmationText: String {
        switch self {
        case .changeLanguage:
            "Vas a cambiar el idioma que utilizas para ver información sobre películas o series."
        case .changeCountry:
            "Si cambias el país los proveedores de películas y series que recibas pueden ser distintos."
        }
    }
    
    var details: String {
        switch self {
        case .changeLanguage, .changeCountry:
            "Estos cambios son locales, para cambiar tus ajustes por defecto visita:"
        }
    }
    
    var question: String {
        switch self {
        case .changeLanguage, .changeCountry:
            "¿Estás seguro?"
        }
    }
    var icon: String {
        switch self {
        case .changeLanguage, .changeCountry:
            "info.circle"
        }
    }
}

struct CustomDialog: View {
    @Binding var show: Bool
    let dialogType: DialogType
//    var onAccept: () -> Void
    var onAccept: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                Image(systemName: dialogType.icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .fontWeight(.light)
                    .foregroundStyle(.bw50)
            }
            VStack(spacing: 8) {
                Text(dialogType.title)
                    .font(.hauora(size: 16, weight: .bold))
                Text(dialogType.confirmationText)
                    .font(.hauora(size: 14))
                    .multilineTextAlignment(.center)
                Text(dialogType.question)
                    .font(.hauora(size: 14, weight: .semibold))
                if !dialogType.details.isEmpty {
                    VStack(spacing: 4) {
                        Text(dialogType.details)
                            .font(.hauora(size: 12))
                            .multilineTextAlignment(.center)
                        Link(destination: URL(string: "https://www.themoviedb.org/settings/account")!) {
                            Text("TMDB")
                                .foregroundStyle(.blue1)
                                .font(.hauora(size: 12))
                        }
                    }
                }
            }
            .foregroundStyle(.white)
            
            HStack(spacing: 10) {
                Button {
                    Task {
                        await onAccept()
                    }
//                    onAccept()
                    dismiss()
                } label: {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.capsuleButton(height: 40, fontSize: 16))
            }
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(.bw20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CustomDialog(show: .constant(true), dialogType: .changeLanguage, onAccept: {})
}

//
//  CustomDialog.swift
//  Movix
//
//  Created by Ancel Dev account on 14/3/25.
//

import SwiftUI

enum DialogType {
    case updateInfo
    case resetPassword
    case deleteAccount
    
    var title: String {
        switch self {
        case .updateInfo: "Actualizar información"
        case .resetPassword: "Restablecer contraseña"
        case .deleteAccount: "Eliminar cuenta"
        }
    }
    var question: String {
        switch self {
        case .updateInfo: "¿Cambiar email?"
        case .resetPassword: "¿Restablecer contraseña?"
        case .deleteAccount: "¿Eliminar permanentemente esta cuenta?"
        }
    }
    var actionDetails: String {
        switch self {
        case .updateInfo, .resetPassword:
            "Se cerrarán todas las sesiones activas en este y otros dispositivos."
        case .deleteAccount:
            "Esta acción no se puede deshacer. Se borrará tu perfil y los datos asociados a tu cuenta. *IMPORTANTE* Eliminar tu cuenta *NO* cancela automáticamente tu suscripción de Apple. Para evitar futuros cobros, debes cancelarla manualmente en los Ajustes de tu iPhone (Suscripciones)"
        }
    }
    
    var icon: Image {
        Image(.triangleWarning)
    }
}

struct CustomDialog: View {
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var errorMessage = false
    @Binding var show: Bool

    let dialogType: DialogType
    var onAccept: () async -> Void
    
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
                dialogType.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                    .fontWeight(.light)
            }
            VStack(spacing: 8) {
                Text(dialogType.question)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(dialogType.actionDetails)
                    .font(.system(size: 14, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.dirtyWhite)
                
                if dialogType == .deleteAccount {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        Button {
                            openURL(url)
                        } label: {
                            Text("Gestionar mi suscripción")
                                .underline()
                                .font(.system(size: 12, design: .rounded))
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .foregroundStyle(.white)
            
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.customBlack)
                }
                .buttonStyle(.capsuleButton(color: .white, textColor: .customBlack, buttonSize: .small))
                .tint(.white)
                
                Button {
                    Task {
                        await onAccept()
                    }
                    dismiss()
                } label: {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.capsuleButton(color: .customRed, textColor: .bw20, buttonSize: .small))
            }
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(.customBlack)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CustomDialog(show: .constant(true), dialogType: .resetPassword, onAccept: {})
}

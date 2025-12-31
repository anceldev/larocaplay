//
//  ResetConfirmationDialog.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

struct ResetConfirmationDialog: View {
    @Binding var show: Bool
    let dialogType: DialogType
//    var onAccept: () -> Void
    var onAccept: () async -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Circle()
                            .frame(width: 28)
                            .overlay(alignment: .center) {
                            Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                Image(.triangleWarning)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .fontWeight(.light)
//                    .foregroundStyle(.white)
            }
            VStack(spacing: 8) {
                Text("¿Restablecer contraseña?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("Se enviará un enlace de recuperación a tu correo electrónico. Por tu seguridad, se cerrarán todas las sesiones activas en este y otros dispositivos.\n\nTendrás que volver a iniciar sesión una vez que hayas actualizado tu contraseña")
                    .font(.system(size: 14, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            
            HStack(spacing: 16) {

                HStack(spacing: 10) {
                    Button {
                        onCancel()
                        //                    onAccept()
                        dismiss()
                    } label: {
                        Text("Cancelar")
                            .frame(maxWidth: .infinity)
                    }
                    //                .buttonStyle(.borderedProminent)
                    .buttonStyle(.capsuleButton(.white, textColor: .customBlack, buttonSize: .small))
                    .tint(.red)
                }
                HStack(spacing: 10) {
                    Button {
                        Task {
                            await onAccept()
                        }
                        //                    onAccept()
                        dismiss()
                    } label: {
                        Text("Confirmar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.capsuleButton(.customRed, textColor: .bw20, buttonSize: .small))
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: 300)
        .background(.customBlack)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

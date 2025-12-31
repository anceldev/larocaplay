//
//  UserDetailsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

struct UserDetailsScreen: View {
    @Environment(AppRouter.self) var router
    @State private var showEditUserDetailsForm = false
    @State private var showResetPasswordForm = false
    var userProfile: UserProfile
    @State private var email = ""
    var body: some View {
        VStack {
            TopBarScreen(title: "Usuario", true)
            VStack {
                Text("Información personal")
                VStack {
                    Text("Nombre")
                    Text(userProfile.displayName ?? "")
                }
                VStack {
                    Text("Correo")
                    Text(userProfile.email ?? "")
                }
                Button {
                    showEditUserDetailsForm.toggle()
                } label: {
                    Text("Editar información")
                }
                Button {
//                    router.navigateTo(.resetPassword)
                    showResetPasswordForm.toggle()
                } label: {
                    Text("Cambiar contraseña")
                }
            }
        }
        .padding(Theme.Padding.normal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .sheet(isPresented: $showEditUserDetailsForm, content: {
            EditUserDetailsForm()
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        })
        .sheet(isPresented: $showResetPasswordForm, content: {
            ResetPasswordForm(email: $email)
                .padding(Theme.Padding.normal)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        })
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func sendResetLink() {
        // TODO: Enviar el link de reseteo. avisar anets al usuario de que se cerrarán sus sesiones, por seguridad. que el pueda confirmar o cancelar.
    }
}

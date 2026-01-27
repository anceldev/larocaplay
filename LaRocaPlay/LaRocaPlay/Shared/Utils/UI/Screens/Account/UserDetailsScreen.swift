//
//  UserDetailsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

private enum EditFieldState {
    case edit
    case save
}

struct UserDetailsScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(AuthManager.self) var authManager
    @Environment(\.modelContext) private var context
    @State private var showDeleteAccountDialog = false
    @State private var showResetPasswordForm = false
    var userProfile: UserProfile
    
    @State private var displayName: String
    @State private var email: String
    @State private var showConfirmEmailChange = false
    
    @State private var editDisplayName = false
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self._displayName = State(initialValue: userProfile.displayName ?? "")
        self._email = State(initialValue: userProfile.email ?? "")
    }
    
    var body: some View {
        VStack {
            TopBarScreen(title: "Mis Datos", true)
            ScrollView(.vertical) {
                VStack(spacing: 24) {
//                    AccountCard(user: userProfile)
                    VStack(spacing: 10) {
                        HStack(alignment: .bottom) {
                            Text("Datos personales")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 6)
                            Spacer()
                        }
                        VStack(spacing: 16) {
                            if self.editDisplayName {
                                EditField()
                            } else {
                                DisplayField()
                            }
                        }
                        .padding()
                        .background(.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    VStack(spacing: 10) {
                        Text("Seguridad")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .padding(.leading, 6)
                        VStack(spacing: 16) {
                            
                            Button {
                                withAnimation(.easeOut) {
                                    showResetPasswordForm = true
                                }
                            } label: {
                                HStack {
                                    Image(.vault3)
                                    Text("Cambiar contraseña")
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    VStack(spacing: 10) {
                        Text("Cuenta")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .padding(.leading, 6)
                        VStack(spacing: 16) {
                            Button {
                                withAnimation(.easeOut) {
                                    showDeleteAccountDialog.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(.trash)
                                        .foregroundStyle(.customRed)
                                    Text("Eliminar cuenta")
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(.red.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                
            }
            .scrollIndicators(.hidden)
            Spacer()
        }
        .padding(Theme.Padding.normal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .popView(
            isPresented: $showDeleteAccountDialog,
            content: {
                CustomDialog(
                    show: $showDeleteAccountDialog,
                    dialogType: .deleteAccount,
                    onAccept: deleteAccount,
                    onCancel: {}
                )
        })
        .sheet(isPresented: $showResetPasswordForm, content: {
            VStack {
                ResetPasswordForm()
            }
            .padding(.horizontal, 18)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        })
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func deleteAccount() async {
        await NotificationManager.shared.unsuscribeFromPrivateCollections(context: context)
        await authManager.deleteAccount()
    }
    private func sendResetLink() {
        // TODO: Enviar el link de reseteo. avisar anets al usuario de que se cerrarán sus sesiones, por seguridad. que el pueda confirmar o cancelar.
    }
    private func saveNewDisplayName() {
        print("Guardar nombre")
        self.editDisplayName = false
    }
    
    @ViewBuilder
    private func EditField() -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(.user)
                TextField("Displayname", text: $displayName)
                    .tint(.white)
                Spacer(minLength: 0)
                Button {
                    saveNewDisplayName()
                } label: {
                    Label("Guardar", image: .circleHalfDottedCheck)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green.opacity(0.5))
                }
            }
            HStack {
                Image(.atSign)
                Text(userProfile.email ?? "")
                Spacer(minLength: 0)
                Label("Protegido", image: .lock)
                    .labelStyle(.iconOnly)
            }
        }
    }
    @ViewBuilder
    private func DisplayField() -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(.user)
                Text(userProfile.displayName ?? "")
                Spacer(minLength: 0)
                Label("Protegido", image: .lock)
                    .labelStyle(.iconOnly)
            }
            HStack {
                Image(.atSign)
                Text(userProfile.email ?? "")
                Spacer(minLength: 0)
                Label("Protegido", image: .lock)
                    .labelStyle(.iconOnly)
            }
        }
    }
}
    

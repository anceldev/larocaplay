//
//  UpdatePasswordForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 6/1/26.
//

import SwiftUI

struct UpdatePasswordForm: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var formModel = UpdatePasswordFormModel()

    
    private enum FocusedField {
        case password, confirmPassword
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var isFormValid: Bool {
        !authManager.isLoading && formModel.isValid
    }
    
    var body: some View {
        VStack(spacing: 32) {
            ScrollView(.vertical) {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Cambio de contraseña")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text("Introduce tu nueva contraseña")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.dirtyWhite)
                    }
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            
                            VStack(alignment: .leading) {
                                HStack(spacing: 0) {
                                    Text("Contraseña")
                                        .foregroundStyle(.white)
                                    Text("*")
                                        .foregroundStyle(.customRed)
                                }
                                .font(.system(size: 14))
                                
                                SecureField("pasword", text: $formModel.password, prompt: Text("Contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .customCapsule(focusedField == .password || !formModel.password.isEmpty)
                                    .focused($focusedField, equals: .password)
                                    .foregroundStyle(.white)
                                    .tint(.white)
                                    .submitLabel(.go)
                                    .animation(.easeInOut, value: focusedField)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                    .withValidation(formModel.$password)
                                
                                
                            }
                            VStack(alignment: .leading) {
                                HStack(spacing: 0) {
                                    Text("Confirmar contraseña")
                                        .foregroundStyle(.white)
                                    Text("*")
                                        .foregroundStyle(.customRed)
                                }
                                .font(.system(size: 14))
                                
                                SecureField("password", text: $formModel.confirmPassword, prompt: Text("Repite la contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .customCapsule(focusedField == .confirmPassword || !formModel.confirmPassword.isEmpty)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .foregroundStyle(.white)
                                    .tint(.white)
                                    .submitLabel(.go)
                                    .animation(.easeInOut, value: focusedField)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                    .withValidation(formModel.$confirmPassword)
                                
                            }
                        }
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                        Button {
                            updatePassword()
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.dirtyWhite)
                            } else {
                                Text("Cambiar contraseña")
                            }
                        }
                        .buttonStyle(.capsuleButton(color: isFormValid ? Theme.Button.normal : Theme.Button.disabled))
                        .disabled(!isFormValid)
                    }
                }
                .animation(.easeInOut, value: isFormValid)
                .onChange(of: focusedField) { oldValue, newValue in
                    switch oldValue {
                    case .password: formModel.validatePassword()
                    case .confirmPassword: formModel.validateConfirmPassword()
                    default: break
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onDisappear {
                authManager.errorMessage = nil
            }
            .enableInjection()
        }
    }
    private func updatePassword() {
        Task {
            await authManager.updatePassword(with: formModel.password, and: formModel.confirmPassword)
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    @Previewable @State var manager = AuthManager(service: AuthService())
    UpdatePasswordForm()
        .environment(manager)
}

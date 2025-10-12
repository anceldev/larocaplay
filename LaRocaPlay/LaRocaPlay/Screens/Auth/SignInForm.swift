//
//  SignInForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct SignInForm: View {
    
    private enum FocusedField {
        case email, password
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var email: String
    @Binding var password: String
    @Binding var isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Iniciar sesión")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Correo")
                                .foregroundStyle(.white)
                            Text("*")
                                .foregroundStyle(.customRed)
                        }
                        .font(.system(size: 14))
                        TextField("email", text: $email, prompt:Text("Correo electrónico").foregroundStyle(.dirtyWhite.opacity(0.3)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .customCapsule(focusedField == .email || !email.isEmpty)
                            .focused($focusedField, equals: .email)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .animation(.easeInOut, value: focusedField)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Contraseña")
                                .foregroundStyle(.white)
                            Text("*")
                                .foregroundStyle(.customRed)
                        }
                        .font(.system(size: 14))
                        
                        SecureField("pasword", text: $password, prompt: Text("Contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .customCapsule(focusedField == .password || !password.isEmpty)
                            .focused($focusedField, equals: .password)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.go)
                            .animation(.easeInOut, value: focusedField)
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                }
                Button {
                    Task {
                        await action()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.dirtyWhite)
                    } else {
                        Text("Iniciar sesión")
                    }
                }
                .buttonStyle(.capsuleButton(.customRed))
                .disabled(isLoading || password.isEmpty || email.isEmpty)
            }
        }
        .padding()
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    SignInForm(email: $email, password: $password, isLoading: .constant(false), action: { })
        .background(.customBlack)
}

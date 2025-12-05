//
//  SignUpForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

enum SignUpError: LocalizedError {
    case passwordsDoNotMatch
    case invalidMail
    case invalidPassword
    case emptyEmail
    case emptyPasswords
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            return "Las contraseñas no coinciden."
        case .invalidMail:
            return "Correo electrónico inválido."
        case .invalidPassword:
            return "Contraseña inválida. Asegurate que tenga al menos 8 caracteres, una mayúscula, una minúscula, un dígito y un carácter especial"
        case .emptyEmail:
            return "Debes introducir un correo electrónico."
        case .emptyPasswords:
            return "Debes introducir una contraseña y confirmarla."
        case .unknownError:
            return "Ocurrió un error inesperado. Por favor, intenta nuevamente más tarde."
        }
    }
}


struct SignUpForm: View {
    private enum FocusedField {
        case email, password, confirmPassword
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var isLoading: Bool
    
    @State private var errorMessage: String? = nil
    
    let action: () async -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Registrarse")
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
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Repetir contraseña")
                                .foregroundStyle(.white)
                            Text("*")
                                .foregroundStyle(.customRed)
                        }
                        .font(.system(size: 14))
                        
                        SecureField("password", text: $confirmPassword, prompt: Text("Repite la contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .customCapsule(focusedField == .confirmPassword || !confirmPassword.isEmpty)
                            .focused($focusedField, equals: .confirmPassword)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.go)
                            .animation(.easeInOut, value: focusedField)
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                }
                if let errorMessage {
                    withAnimation(.easeIn) {
                        
                        Text(errorMessage)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 14))
                    }
                }
                Button {
                    signUpAction()
                    
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.dirtyWhite)
                    } else {
                        Text("Registrarse")
                    }
                }
                .buttonStyle(.capsuleButton(.customRed))
                .disabled(isLoading)
            }
        }
        .padding()
        .enableInjection()
    }
    
    private func signUpAction() {
        Task {
            do {
                try checkEmailField()
                try checkPasswordsField()
                await action()
            } catch (let error as SignUpError) {
                self.errorMessage = error.errorDescription
            } catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func checkEmailField() throws {
        if email.isEmpty {
            throw SignUpError.emptyEmail
        }
        if !isValidEmail(email) {
            throw SignUpError.invalidMail
        }
    }
    
    private func checkPasswordsField() throws {
        if password.isEmpty || confirmPassword.isEmpty {
            throw SignUpError.emptyPasswords
        }
        if password == confirmPassword {
            if isValidPassword(password) { return }
            throw SignUpError.invalidPassword
        } else {
            throw SignUpError.passwordsDoNotMatch
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        return predicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Al menos 8 caracteres, una mayúscula, una minúscula, un dígito y un carácter especial
        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$&*.,?+-]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    @Previewable @State var confirmPassword = ""
    
    SignUpForm(email: $email, password: $password, confirmPassword: $confirmPassword, isLoading: .constant(false), action: {})
        .background(.customBlack)
}

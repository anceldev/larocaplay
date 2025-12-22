//
//  Validations.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 8/12/25.
//

import Foundation

final class Validations {
    static var shared = Validations()
    
    func isValidEmail(_ email: String) throws {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SignUpError.emptyEmail
        }
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        if predicate.evaluate(with: email) { return }
        throw SignUpError.invalidMail
    }
    
//    func isValidEmail(_ email: String) throws -> Bool {
//        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            throw SignUpError.emptyEmail
//        }
//        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
//        
//        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
//        return predicate.evaluate(with: email)
//    }
    
//    func isValidPassword(_ password: String) -> Bool {
//        // Al menos 8 caracteres, una mayúscula, una minúscula, un dígito y un carácter especial
//        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$&*.,?+-]).{8,}$"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//        return predicate.evaluate(with: password)
//    }
    func isValidPassword(_ password: String) throws {
        // Al menos 8 caracteres, una mayúscula, una minúscula, un dígito y un carácter especial
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SignUpError.emptyPasswords
        }
        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$&*.,?+-]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//        return predicate.evaluate(with: password)
        if predicate.evaluate(with: password) {
            return
        }
        throw SignUpError.invalidPassword
    }
}
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

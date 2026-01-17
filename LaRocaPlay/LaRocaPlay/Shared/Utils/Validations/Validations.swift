//
//  Validations.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 8/12/25.
//

import Foundation
import SwiftUI

enum SignUpError: LocalizedError {
    case passwordsDoNotMatch
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            return "Las contraseñas no coinciden."
        case .unknownError:
            return "Ocurrió un error inesperado. Por favor, intenta nuevamente más tarde."
        }
    }
}

enum RegexExpression: String {
    case email = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
    // Requisitos: una mayuscula, una minuscula, un digito y un caracter especial entre ! @ # $ & * . , ? + -
    case password = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$&*.,?+-]).{8,}$"
}

enum ValidationRule {
    case required(String)
    case regularExpression(RegexExpression, String)
//    case matches(() -> String, String)
}

@propertyWrapper
struct Validate<T: Equatable> {

    private var value: T
    private var rules: [ValidationRule]
    private var shouldValidate = false

    var wrappedValue: T {
        get { value }
        set { value = newValue }
    }

    var projectedValue: String? {
        guard shouldValidate else { return nil }

        for rule in rules {
            if let message = validate(rule: rule) {
                return message
            }
        }
        return nil
    }

    mutating func validateNow() {
        shouldValidate = true
    }

    private func validate(rule: ValidationRule) -> String? {
        switch rule {
        case .required(let message):
            return validateRequired(message: message)
        case .regularExpression(let regexExpression, let message):
            return validateRegex(pattern: regexExpression.rawValue, message: message)
        }
    }

    private func validateRequired(message: String) -> String? {
        if let stringValue = value as? String,
           stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return message
        }
        return nil
    }

    private func validateRegex(pattern: String, message: String) -> String? {
        guard let stringValue = value as? String else { return nil }

        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: stringValue.utf16.count)

        return regex?.firstMatch(in: stringValue, options: [], range: range) == nil
            ? message
            : nil
    }

    init(wrappedValue: T, _ rules: ValidationRule...) {
        self.value = wrappedValue
        self.rules = rules
    }
}
extension Validate {
    var isValid: Bool {
        for rule in rules {
            if validate(rule: rule) != nil {
                return false
            }
        }
        return true
    }
}




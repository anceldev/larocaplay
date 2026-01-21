//
//  UpdatePasswordFormModel.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 7/1/26.
//

import Foundation

struct UpdatePasswordFormModel {
    
    @Validate(
        .required("Se requiere contraseña."),
        .regularExpression(.password, "Formato erroneo de contraseña.")
    ) var password: String = ""
    @Validate(
        .required("Confirma la contraseña."),
        .regularExpression(.password, "Formato erroneo de contraseña."),
    ) var confirmPassword: String = ""
    
    var isValid: Bool {
        _password.isValid &&
        _confirmPassword.isValid &&
        password == confirmPassword
    }
    
    
    mutating func validatePassword() {
        _password.validateNow()
    }
    mutating func validateConfirmPassword() {
        _confirmPassword.validateNow()
    }
    mutating func validateAll() {
        _password.validateNow()
        _confirmPassword.validateNow()
    }
}
struct SignupFormModel {
    @Validate(
        .required("Se requiere correo."),
        .regularExpression(.email, "Formato erroneo de contraseña.")
    )
    var email: String = ""
    
    @Validate(
        .required("Se requiere contraseña."),
        .regularExpression(.password, "Formato erroneo de contraseña.")
    )
    var password: String = ""
    
    @Validate(
        .required("Confirma la contraseña."),
        .regularExpression(.password, "Formato erroneo de contraseña.")
    )
    var confirmPassword: String = ""
    
    var isValid: Bool {
        _email.isValid &&
        _password.isValid &&
        _confirmPassword.isValid &&
        password == confirmPassword
    }
    
    mutating func validateEmail() {
        _email.validateNow()
    }
    mutating func validatePassword() {
        _password.validateNow()
    }
    mutating func validateConfirmPassword() {
        _confirmPassword.validateNow()
    }
}
struct SigninFormModel {
    @Validate(
        .required("Se requiere correo."),
        .regularExpression(.email, "Formato erroneo de contraseña.")
    )
    var email: String = ""
    
    @Validate(
        .required("Se requiere contraseña."),
        .regularExpression(.password, "Formato erroneo de contraseña.")
    )
    var password: String = ""
    
    var isValid: Bool {
        _email.isValid && _password.isValid
    }
    
    mutating func validateEmail() {
        _email.validateNow()
    }
    mutating func validatePassword() {
        _password.validateNow()
    }
}

struct ResetPasswordFormModel {
    @Validate(
        .required("Se requiere correo."),
        .regularExpression(.email, "Formato erroneo de contraseña.")
    )
    var email: String = ""
    
    var isValid: Bool {
        _email.isValid
    }
    
    mutating func validateEmail() {
        _email.validateNow()
    }
}

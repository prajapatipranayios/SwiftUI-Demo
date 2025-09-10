//
//  ValidationHelper.swift
//

import Foundation

enum ValidationResult {
    case success
    case failure(String)   // return only error message
}

// MARK: - Centralized Validation Messages
enum ValidationMessage: String {
    case nameRequired = "Name is required"
    case lastNameRequired = "Last name is required"
    case emailRequired = "Email is required"
    case invalidEmail = "Invalid email address"
    case phoneRequired = "Phone number is required"
    case invalidPhone = "Invalid phone number"
    case passwordRequired = "Password is required"
    case confirmPasswordRequired = "Confirm password is required"
    case passwordMismatch = "Passwords do not match"
    case weakPassword = "Password must have at least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character"
    case amountRequired = "Amount is required"
    case invalidAmount = "Enter valid amount"
    case startDateRequired = "Start date is required"
    case endDateRequired = "End date is required"
    case invalidDateRange = "Start date must be before end date"
    case futureDateRequired = "Date must be in the future"
    case imageRequired = "Image is required"
    case selectionRequired = "Selection is required"
    case checkboxRequired = "You must accept this option"
}

class ValidationHelper {
    
    // MARK: - Empty / Required
    static func isRequired(_ value: String, message: ValidationMessage) -> ValidationResult {
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .failure(message.rawValue)
            : .success
    }
    
    // MARK: - Length
    static func hasValidLength(_ value: String, min: Int, max: Int, message: ValidationMessage) -> ValidationResult {
        if value.count < min || value.count > max {
            return .failure(message.rawValue)
        }
        return .success
    }
    
    // MARK: - Email
    static func isValidEmail(_ email: String, message: ValidationMessage) -> ValidationResult {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
            ? .success
            : .failure(message.rawValue)
    }
    
    // MARK: - Phone Numbers
    static func isValidPhone(_ phone: String, message: ValidationMessage) -> ValidationResult {
        let regex = "^[0-9]{7,15}$" // generic international phone number
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
            ? .success
            : .failure(message.rawValue)
    }
    
    static func isValidIndianPhone(_ phone: String, message: ValidationMessage) -> ValidationResult {
        let regex = "^[6-9]\\d{9}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
            ? .success
            : .failure(message.rawValue)
    }
    
    // MARK: - Password
    static func isValidPassword(_ password: String, message: ValidationMessage) -> ValidationResult {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special char
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
            ? .success
            : .failure(message.rawValue)
    }
    
    static func doPasswordsMatch(_ password: String, _ confirm: String, message: ValidationMessage) -> ValidationResult {
        return password == confirm ? .success : .failure(message.rawValue)
    }
    
    // MARK: - Numeric / Money
    static func isNumeric(_ value: String, message: ValidationMessage) -> ValidationResult {
        return Double(value) != nil ? .success : .failure(message.rawValue)
    }
    
    static func isPositiveNumber(_ value: String, message: ValidationMessage) -> ValidationResult {
        if let num = Double(value), num > 0 {
            return .success
        }
        return .failure(message.rawValue)
    }
    
    // MARK: - Dates
    static func isStartBeforeEnd(start: Date, end: Date, message: ValidationMessage) -> ValidationResult {
        return start < end ? .success : .failure(message.rawValue)
    }
    
    static func isFutureDate(_ date: Date, message: ValidationMessage) -> ValidationResult {
        return date > Date() ? .success : .failure(message.rawValue)
    }
    
    // MARK: - Selections
    static func isChecked(_ value: Bool, message: ValidationMessage) -> ValidationResult {
        return value ? .success : .failure(message.rawValue)
    }
    
    static func isSelected(_ value: String, message: ValidationMessage) -> ValidationResult {
        return value.isEmpty ? .failure(message.rawValue) : .success
    }
    
    // MARK: - Files / Images
    static func isImageSelected(_ selected: Bool, message: ValidationMessage) -> ValidationResult {
        return selected ? .success : .failure(message.rawValue)
    }
}

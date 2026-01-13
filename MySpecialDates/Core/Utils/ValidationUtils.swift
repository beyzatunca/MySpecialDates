import Foundation

struct ValidationUtils {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        // Trim whitespace
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        guard !trimmedEmail.isEmpty else {
            return false
        }
        
        // Improved email regex - more permissive
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: trimmedEmail)
    }
    
    // MARK: - Detailed Email Validation
    enum EmailValidationResult {
        case valid
        case empty
        case missingAtSymbol
        case invalidFormat
        case invalidDomain
        case invalidTopLevelDomain
        
        func errorMessage() -> String {
            switch self {
            case .valid:
                return ""
            case .empty:
                return "Email adresi geçersiz.\n\nEmail gereksinimleri:\n• Email adresi boş olamaz\n\nLütfen geçerli bir email adresi girin (örnek: kullanici@example.com)"
            case .missingAtSymbol:
                return "Email adresi geçersiz.\n\nEmail gereksinimleri:\n• Email adresi '@' sembolü içermelidir\n\nLütfen geçerli bir email adresi girin (örnek: kullanici@example.com)"
            case .invalidFormat:
                return "Email adresi geçersiz.\n\nEmail gereksinimleri:\n• Email adresi geçerli bir formatta olmalıdır\n• Örnek format: kullanici@example.com\n\nLütfen email adresinizi kontrol edin."
            case .invalidDomain:
                return "Email adresi geçersiz.\n\nEmail gereksinimleri:\n• Email adresi geçerli bir domain içermelidir\n• Örnek: kullanici@example.com\n\nLütfen email adresinizi kontrol edin."
            case .invalidTopLevelDomain:
                return "Email adresi geçersiz.\n\nEmail gereksinimleri:\n• Email adresi geçerli bir üst seviye domain içermelidir (.com, .org, .net vb.)\n• Örnek: kullanici@example.com\n\nLütfen email adresinizi kontrol edin."
            }
        }
    }
    
    static func validateEmail(_ email: String) -> EmailValidationResult {
        // Trim whitespace
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        guard !trimmedEmail.isEmpty else {
            return .empty
        }
        
        // Check for @ symbol
        guard trimmedEmail.contains("@") else {
            return .missingAtSymbol
        }
        
        // Split by @
        let parts = trimmedEmail.components(separatedBy: "@")
        guard parts.count == 2 else {
            return .invalidFormat
        }
        
        let localPart = parts[0]
        let domainPart = parts[1]
        
        // Check local part
        guard !localPart.isEmpty, localPart.count <= 64 else {
            return .invalidFormat
        }
        
        // Check domain part
        guard !domainPart.isEmpty else {
            return .invalidDomain
        }
        
        // Check for top-level domain
        let domainParts = domainPart.components(separatedBy: ".")
        guard domainParts.count >= 2 else {
            return .invalidTopLevelDomain
        }
        
        let topLevelDomain = domainParts.last ?? ""
        guard topLevelDomain.count >= 2 && topLevelDomain.count <= 64 else {
            return .invalidTopLevelDomain
        }
        
        // Final regex check
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            return .invalidFormat
        }
        
        return .valid
    }
    
    // MARK: - Password Validation (Simplified)
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters
        return password.count >= 8
    }
    
    // MARK: - Detailed Password Validation
    enum PasswordValidationResult {
        case valid
        case tooShort(Int) // current length
        case tooLong
        
        func errorMessage() -> String {
            switch self {
            case .valid:
                return ""
            case .tooShort(let currentLength):
                let remaining = 8 - currentLength
                return "Şifre geçersiz.\n\nŞifre gereksinimleri:\n• En az 8 karakter olmalıdır\n\nŞu anda şifreniz \(currentLength) karakter içeriyor. \(remaining) karakter daha eklemeniz gerekiyor."
            case .tooLong:
                return "Şifre geçersiz.\n\nŞifre gereksinimleri:\n• En fazla 128 karakter olabilir\n\nLütfen şifrenizi kısaltın."
            }
        }
    }
    
    static func validatePassword(_ password: String) -> PasswordValidationResult {
        if password.count < 8 {
            return .tooShort(password.count)
        } else if password.count > 128 {
            return .tooLong
        } else {
            return .valid
        }
    }
    
    // MARK: - Phone Number Validation
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String) -> Bool {
        return name.count >= 2 && name.count <= 50
    }
    
    // MARK: - Age Validation
    static func isValidAge(_ birthDate: Date) -> Bool {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return age >= 13 && age <= 120
    }
}

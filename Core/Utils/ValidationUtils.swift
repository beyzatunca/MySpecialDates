import Foundation

struct ValidationUtils {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation (Simplified)
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters
        return password.count >= 8
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

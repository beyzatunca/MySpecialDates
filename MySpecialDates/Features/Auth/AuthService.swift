import Foundation
import Combine

enum AuthError: Error, LocalizedError {
    case invalidEmail(String) // Detaylı hata mesajı
    case invalidPassword(String) // Detaylı hata mesajı
    case invalidName
    case invalidAge
    case invalidPhoneNumber
    case userNotFound
    case userAlreadyExists
    case invalidCredentials
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail(let message):
            return message
        case .invalidPassword(let message):
            return message
        case .invalidName:
            return "Geçersiz isim. İsim en az 2, en fazla 50 karakter olmalıdır."
        case .invalidAge:
            return "Geçersiz yaş. Yaşınız 13 ile 120 arasında olmalıdır."
        case .invalidPhoneNumber:
            return "Geçersiz telefon numarası. Lütfen geçerli bir telefon numarası girin."
        case .userNotFound:
            return "Kullanıcı bulunamadı"
        case .userAlreadyExists:
            return "Bu email adresi zaten kayıtlı"
        case .invalidCredentials:
            return "Geçersiz email veya şifre"
        case .networkError:
            return "Ağ hatası"
        case .unknown:
            return "Bilinmeyen hata"
        }
    }
}

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String, birthDate: Date) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() -> User?
}

class AuthService: AuthServiceProtocol {
    private let userRepository: UserRepositoryProtocol
    private var currentUser: User?
    
    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String, birthDate: Date) async throws -> User {
        
        // Validation
        let emailValidation = ValidationUtils.validateEmail(email)
        guard case .valid = emailValidation else {
            throw AuthError.invalidEmail(emailValidation.errorMessage())
        }
        
        let passwordValidation = ValidationUtils.validatePassword(password)
        guard case .valid = passwordValidation else {
            throw AuthError.invalidPassword(passwordValidation.errorMessage())
        }
        
        guard ValidationUtils.isValidName(firstName) && ValidationUtils.isValidName(lastName) else {
            throw AuthError.invalidName
        }
        
        guard ValidationUtils.isValidAge(birthDate) else {
            throw AuthError.invalidAge
        }
        
        guard ValidationUtils.isValidPhoneNumber(phoneNumber) else {
            throw AuthError.invalidPhoneNumber
        }
        
        // Check if user already exists
        if (try await userRepository.getUserByEmail(email)) != nil {
            throw AuthError.userAlreadyExists
        }
        
        // Create new user
        let user = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            birthDate: birthDate,
            authType: .email
        )
        
        // Save user
        try await userRepository.saveUser(user)
        currentUser = user
        
        return user
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> User {
        
        // Validation
        let emailValidation = ValidationUtils.validateEmail(email)
        guard case .valid = emailValidation else {
            throw AuthError.invalidEmail(emailValidation.errorMessage())
        }
        
        let passwordValidation = ValidationUtils.validatePassword(password)
        guard case .valid = passwordValidation else {
            throw AuthError.invalidPassword(passwordValidation.errorMessage())
        }
        
        // Get user
        guard let user = try await userRepository.getUserByEmail(email) else {
            throw AuthError.userNotFound
        }
        
        // TODO: Add password verification logic
        // For now, just check if user exists
        
        currentUser = user
        return user
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        currentUser = nil
    }
    
    // MARK: - Get Current User
    func getCurrentUser() -> User? {
        return currentUser
    }
}

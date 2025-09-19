import Foundation
import Combine

enum AuthError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword
    case userNotFound
    case userAlreadyExists
    case invalidCredentials
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Geçersiz email adresi"
        case .invalidPassword:
            return "Geçersiz şifre"
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
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?, birthDate: Date) async throws -> User
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
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?, birthDate: Date) async throws -> User {
        
        // Validation
        guard ValidationUtils.isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard ValidationUtils.isValidPassword(password) else {
            throw AuthError.invalidPassword
        }
        
        guard ValidationUtils.isValidName(firstName) && ValidationUtils.isValidName(lastName) else {
            throw AuthError.invalidEmail
        }
        
        guard ValidationUtils.isValidAge(birthDate) else {
            throw AuthError.invalidEmail
        }
        
        // Check if user already exists
        if let existingUser = try await userRepository.getUserByEmail(email) {
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
        guard ValidationUtils.isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard ValidationUtils.isValidPassword(password) else {
            throw AuthError.invalidPassword
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

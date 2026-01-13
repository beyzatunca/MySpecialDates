import Foundation
import AuthenticationServices
// import FirebaseAuth
import CryptoKit

// MARK: - Apple Sign-In Service Protocol
@MainActor
protocol AppleSignInServiceProtocol {
    func signInWithApple() async throws -> FirestoreUser
    func signOut() async throws
    func getCurrentUser() -> FirestoreUser?
}

// MARK: - Apple Sign-In Service Implementation
@MainActor
class AppleSignInService: NSObject, ObservableObject, AppleSignInServiceProtocol {
    private let firebaseService: FirebaseEventServiceProtocol
    private var currentNonce: String?
    
    @Published var isAuthenticated = false
    @Published var currentUser: FirestoreUser?
    
    init(firebaseService: FirebaseEventServiceProtocol) {
        self.firebaseService = firebaseService
        super.init()
        
        // Check if user is already signed in
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    // MARK: - Authentication Status
    
    private func checkAuthenticationStatus() async {
        if let user = try? await firebaseService.getCurrentUser() {
            currentUser = user
            isAuthenticated = true
        } else {
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Apple Sign-In
    
    func signInWithApple() async throws -> FirestoreUser {
        // Simülatörde Apple Sign-In problemi olduğu için direkt mock kullanıcı oluştur
        print("🍎 Apple Sign-In başlatılıyor...")
        
        // Kısa bir delay ekleyerek loading spinner'ı göster
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye
        
        let mockUser = FirestoreUser(
            id: "mock-user-id-\(UUID().uuidString)", // ID'yi açıkça set et
            email: "test@example.com",
            displayName: "Test User",
            photoURL: nil,
            provider: "apple.com",
            providerID: "mock-apple-id",
            appleUserID: "mock-apple-id",
            realUserStatus: "1"
        )
        
        try await firebaseService.saveUser(mockUser)
        
        // Update local state
        currentUser = mockUser
        isAuthenticated = true
        
        print("✅ Mock Apple Sign-In başarılı: \(mockUser.displayName)")
        return mockUser
        
        /* Gerçek Apple Sign-In kodu (simülatör problemi nedeniyle devre dışı)
        return try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        */
    }
    
    private var signInContinuation: CheckedContinuation<FirestoreUser, Error>?
    
    func signOut() async throws {
        // Mock: Simulate sign out
        currentUser = nil
        isAuthenticated = false
        print("✅ Mock: Apple Sign-In ile çıkış yapıldı")
    }
    
    func getCurrentUser() -> FirestoreUser? {
        return currentUser
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            signInContinuation?.resume(throwing: AppleSignInError.invalidCredential)
            return
        }
        
        guard let nonce = currentNonce else {
            signInContinuation?.resume(throwing: AppleSignInError.invalidNonce)
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            signInContinuation?.resume(throwing: AppleSignInError.invalidToken)
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            signInContinuation?.resume(throwing: AppleSignInError.tokenEncodingError)
            return
        }
        
        // Mock: Simulate successful Apple Sign-In
        Task {
            do {
                // Create mock user
                let displayName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let firestoreUser = FirestoreUser(
                    email: appleIDCredential.email ?? "test@example.com",
                    displayName: displayName.isEmpty ? "Apple User" : displayName,
                    photoURL: nil,
                    provider: "apple.com",
                    providerID: appleIDCredential.user,
                    appleUserID: appleIDCredential.user,
                    realUserStatus: "\(appleIDCredential.realUserStatus.rawValue)"
                )
                
                try await firebaseService.saveUser(firestoreUser)
                
                // Update local state
                currentUser = firestoreUser
                isAuthenticated = true
                
                signInContinuation?.resume(returning: firestoreUser)
                print("✅ Mock: Apple Sign-In başarılı: \(firestoreUser.displayName)")
                
            } catch {
                signInContinuation?.resume(throwing: error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Simülatörde Apple Sign-In hatası durumunda mock kullanıcı oluştur
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled, .failed, .invalidResponse, .notHandled, .unknown:
                // Mock kullanıcı oluştur
                Task {
                    let mockUser = FirestoreUser(
                        email: "test@example.com",
                        displayName: "Test User",
                        photoURL: nil,
                        provider: "apple.com",
                        providerID: "mock-apple-id",
                        appleUserID: "mock-apple-id",
                        realUserStatus: "1"
                    )
                    
                    try await firebaseService.saveUser(mockUser)
                    currentUser = mockUser
                    isAuthenticated = true
                    
                    signInContinuation?.resume(returning: mockUser)
                    print("✅ Mock Apple Sign-In başarılı (simülatör hatası nedeniyle): \(mockUser.displayName)")
                }
                return
            default:
                break
            }
        }
        signInContinuation?.resume(throwing: error)
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window
            }
        } else {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                return window
            }
        }
        // Fallback: Return a default anchor
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window
        }
        return ASPresentationAnchor()
    }
}

// MARK: - Apple Sign-In Error
enum AppleSignInError: Error, LocalizedError {
    case invalidCredential
    case invalidNonce
    case invalidToken
    case tokenEncodingError
    case firebaseError(String)
    case userCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Geçersiz Apple kimlik bilgisi"
        case .invalidNonce:
            return "Geçersiz nonce değeri"
        case .invalidToken:
            return "Geçersiz Apple token"
        case .tokenEncodingError:
            return "Token kodlama hatası"
        case .firebaseError(let message):
            return "Firebase hatası: \(message)"
        case .userCreationFailed:
            return "Kullanıcı oluşturma başarısız"
        }
    }
}

// MARK: - Mock Apple Sign-In Service (for testing)
class MockAppleSignInService: AppleSignInServiceProtocol {
    @Published var isAuthenticated = false
    @Published var currentUser: FirestoreUser?
    
    func signInWithApple() async throws -> FirestoreUser {
        // Simulate successful sign-in
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        
        let mockUser = FirestoreUser(
            email: "test@example.com",
            displayName: "Test User",
            provider: "apple.com",
            providerID: "mock-user-id",
            appleUserID: "mock-apple-id"
        )
        
        currentUser = mockUser
        isAuthenticated = true
        
        print("Mock: Apple Sign-In başarılı: \(mockUser.displayName)")
        return mockUser
    }
    
    func signOut() async throws {
        currentUser = nil
        isAuthenticated = false
        print("Mock: Apple Sign-In ile çıkış yapıldı")
    }
    
    func getCurrentUser() -> FirestoreUser? {
        return currentUser
    }
}

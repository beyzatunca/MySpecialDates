import Foundation
// import FirebaseCore
// import FirebaseAuth
// import FirebaseFirestore

// MARK: - Firebase Configuration Manager
class FirebaseConfiguration {
    static let shared = FirebaseConfiguration()
    
    private init() {}
    
    func configure() {
        // Firebase yapılandırması - şimdilik mock
        print("✅ Mock Firebase yapılandırması")
    }
    
    func getCurrentUser() -> String? {
        // Mock kullanıcı
        return "mock-user-id"
    }
    
    func signOut() throws {
        print("✅ Mock kullanıcı çıkış yaptı")
    }
}

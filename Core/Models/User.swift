import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let birthDate: Date
    let authType: AuthType
    let createdAt: Date
    let updatedAt: Date
    
    enum AuthType: String, Codable, CaseIterable {
        case email = "r"      // Regular email/password
        case facebook = "f"   // Facebook login
        case apple = "a"      // Apple login
        
        var displayName: String {
            switch self {
            case .email: return "Email"
            case .facebook: return "Facebook"
            case .apple: return "Apple"
            }
        }
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    init(id: String = UUID().uuidString,
         firstName: String,
         lastName: String,
         email: String,
         phoneNumber: String? = nil,
         birthDate: Date,
         authType: AuthType,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.authType = authType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - User Extensions
extension User {
    static var mock: User {
        User(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phoneNumber: "+1234567890",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
            authType: .email
        )
    }
}

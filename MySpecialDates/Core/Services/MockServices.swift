import Foundation
import Contacts

// MARK: - Firebase Repository Errors
enum FirebaseRepositoryError: Error, LocalizedError {
    case userNotAuthenticated
    case documentNotFound
    case networkError
    case permissionDenied
    case invalidData
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Kullanıcı giriş yapmamış"
        case .documentNotFound:
            return "Belge bulunamadı"
        case .networkError:
            return "Ağ hatası"
        case .permissionDenied:
            return "İzin reddedildi"
        case .invalidData:
            return "Geçersiz veri"
        case .unknown:
            return "Bilinmeyen hata"
        }
    }
}

// MARK: - Contact Access Errors
enum ContactAccessError: Error, LocalizedError {
    case permissionDenied
    case permissionRestricted
    case accessError
    case fetchError
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Kişi listesine erişim reddedildi. Lütfen ayarlardan izin verin."
        case .permissionRestricted:
            return "Kişi listesine erişim kısıtlandı."
        case .accessError:
            return "Kişi listesine erişim hatası."
        case .fetchError:
            return "Kişiler getirilirken hata oluştu."
        }
    }
}

// MARK: - Firebase User Repository Protocol
protocol FirebaseUserRepositoryProtocol {
    // User operations
    func getCurrentUser() async throws -> FirebaseUserModel?
    func saveCurrentUser(_ user: FirebaseUserModel) async throws
    func updateCurrentUser(_ user: FirebaseUserModel) async throws
    
    // User search operations
    func searchUsersByEmail(_ email: String) async throws -> [FirebaseUserModel]
    func searchUsersByPhone(_ phoneNumber: String) async throws -> [FirebaseUserModel]
    func getUserById(_ userId: String) async throws -> FirebaseUserModel?
    
    // Contact operations
    func saveContacts(_ contacts: [ContactEntry], for userId: String) async throws
    func getContacts(for userId: String) async throws -> [ContactEntry]
    func deleteAllContacts(for userId: String) async throws
    
    // Birthday operations
    func saveBirthdays(_ birthdays: [BirthdayEntry], for userId: String) async throws
    func getBirthdays(for userId: String) async throws -> [BirthdayEntry]
    func addBirthday(_ birthday: BirthdayEntry, for userId: String) async throws
    func deleteBirthday(_ birthdayId: String, for userId: String) async throws
}

// MARK: - Firebase Auth Service Protocol
@MainActor
protocol FirebaseAuthServiceProtocol {
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?, birthDate: Date) async throws -> FirebaseUserModel
    func signIn(email: String, password: String) async throws -> FirebaseUserModel
    func signOut() async throws
    func getCurrentUser() -> FirebaseUserModel?
    func updateUserProfile(_ user: FirebaseUserModel) async throws
}

// MARK: - Birthday Manager Protocol
protocol BirthdayManagerProtocol {
    func findMatchingUsers(for contacts: [ContactModel]) async throws -> [(ContactModel, FirebaseUserModel)]
    func createBirthdayEntries(from matches: [(ContactModel, FirebaseUserModel)]) async throws -> [BirthdayEntry]
    func syncBirthdaysToFirestore(_ birthdays: [BirthdayEntry], for userId: String) async throws
    func processContactSync(for userId: String) async throws -> (contacts: [ContactEntry], birthdays: [BirthdayEntry])
}

// MARK: - Contact Access Service Protocol
protocol ContactAccessServiceProtocol {
    func requestPermission() async throws -> Bool
    func fetchContacts() async throws -> [ContactModel]
    func getPermissionStatus() -> CNAuthorizationStatus
}

// MARK: - Mock Firebase User Repository
@MainActor
class MockFirebaseUserRepository: FirebaseUserRepositoryProtocol {
    private var mockUsers: [String: FirebaseUserModel] = [:]
    private var mockContacts: [String: [ContactEntry]] = [:]
    private var mockBirthdays: [String: [BirthdayEntry]] = [:]
    
    // MARK: - User Operations
    func getCurrentUser() async throws -> FirebaseUserModel? {
        // Mock current user
        return FirebaseUserModel(
            uid: "mock-user-id",
            firstName: "Mock",
            lastName: "User",
            email: "mock@example.com",
            phoneNumber: "+1234567890",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date()),
            isBirthdayPublic: true
        )
    }
    
    func saveCurrentUser(_ user: FirebaseUserModel) async throws {
        mockUsers[user.uid] = user
    }
    
    func updateCurrentUser(_ user: FirebaseUserModel) async throws {
        mockUsers[user.uid] = user
    }
    
    // MARK: - User Search Operations
    func searchUsersByEmail(_ email: String) async throws -> [FirebaseUserModel] {
        return mockUsers.values.filter { $0.email.lowercased() == email.lowercased() }
    }
    
    func searchUsersByPhone(_ phoneNumber: String) async throws -> [FirebaseUserModel] {
        return mockUsers.values.filter { $0.phoneNumber == phoneNumber }
    }
    
    func getUserById(_ userId: String) async throws -> FirebaseUserModel? {
        return mockUsers[userId]
    }
    
    // MARK: - Contact Operations
    func saveContacts(_ contacts: [ContactEntry], for userId: String) async throws {
        mockContacts[userId] = contacts
    }
    
    func getContacts(for userId: String) async throws -> [ContactEntry] {
        return mockContacts[userId] ?? []
    }
    
    func deleteAllContacts(for userId: String) async throws {
        mockContacts[userId] = []
    }
    
    // MARK: - Birthday Operations
    func saveBirthdays(_ birthdays: [BirthdayEntry], for userId: String) async throws {
        mockBirthdays[userId] = birthdays
    }
    
    func getBirthdays(for userId: String) async throws -> [BirthdayEntry] {
        return mockBirthdays[userId] ?? []
    }
    
    func addBirthday(_ birthday: BirthdayEntry, for userId: String) async throws {
        var birthdays = mockBirthdays[userId] ?? []
        birthdays.append(birthday)
        mockBirthdays[userId] = birthdays
    }
    
    func deleteBirthday(_ birthdayId: String, for userId: String) async throws {
        var birthdays = mockBirthdays[userId] ?? []
        birthdays.removeAll { $0.id == birthdayId }
        mockBirthdays[userId] = birthdays
    }
}

// MARK: - Mock Firebase Auth Service
@MainActor
class MockFirebaseAuthService: FirebaseAuthServiceProtocol {
    private var mockCurrentUser: FirebaseUserModel?
    
    func signUp(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?, birthDate: Date) async throws -> FirebaseUserModel {
        let user = FirebaseUserModel(
            uid: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            birthDate: birthDate,
            isBirthdayPublic: true
        )
        mockCurrentUser = user
        return user
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseUserModel {
        // Mock successful login
        let user = FirebaseUserModel(
            uid: "mock-user-id",
            firstName: "Mock",
            lastName: "User",
            email: email,
            phoneNumber: "+1234567890",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date()),
            isBirthdayPublic: true
        )
        mockCurrentUser = user
        return user
    }
    
    func signOut() async throws {
        mockCurrentUser = nil
    }
    
    func getCurrentUser() -> FirebaseUserModel? {
        return mockCurrentUser
    }
    
    func updateUserProfile(_ user: FirebaseUserModel) async throws {
        mockCurrentUser = user
    }
}

// MARK: - Mock Birthday Manager
@MainActor
class MockBirthdayManager: BirthdayManagerProtocol {
    private let firebaseRepository: FirebaseUserRepositoryProtocol
    
    init(firebaseRepository: FirebaseUserRepositoryProtocol) {
        self.firebaseRepository = firebaseRepository
    }
    
    convenience init() {
        self.init(firebaseRepository: MockFirebaseUserRepository())
    }
    
    func findMatchingUsers(for contacts: [ContactModel]) async throws -> [(ContactModel, FirebaseUserModel)] {
        // Mock some matches
        var matches: [(ContactModel, FirebaseUserModel)] = []
        
        for contact in contacts.prefix(2) {
            let mockUser = FirebaseUserModel(
                uid: UUID().uuidString,
                firstName: contact.name.components(separatedBy: " ").first ?? "Mock",
                lastName: contact.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                email: contact.primaryEmail ?? "mock@example.com",
                phoneNumber: contact.primaryPhone,
                birthDate: Calendar.current.date(byAdding: .year, value: -Int.random(in: 20...60), to: Date()),
                isBirthdayPublic: true
            )
            matches.append((contact, mockUser))
        }
        
        return matches
    }
    
    func createBirthdayEntries(from matches: [(ContactModel, FirebaseUserModel)]) async throws -> [BirthdayEntry] {
        return matches.compactMap { (contact, user) in
            guard let birthDate = user.birthDate else { return nil }
            return BirthdayEntry(
                contactName: contact.name,
                contactId: contact.id,
                birthday: birthDate,
                type: .birthday,
                isFromContact: true
            )
        }
    }
    
    func syncBirthdaysToFirestore(_ birthdays: [BirthdayEntry], for userId: String) async throws {
        try await firebaseRepository.saveBirthdays(birthdays, for: userId)
    }
    
    func processContactSync(for userId: String) async throws -> (contacts: [ContactEntry], birthdays: [BirthdayEntry]) {
        let contacts = try await firebaseRepository.getContacts(for: userId)
        let birthdays = try await firebaseRepository.getBirthdays(for: userId)
        return (contacts: contacts, birthdays: birthdays)
    }
}

// MARK: - Mock Contact Access Service with Sample Data
class MockContactAccessServiceWithData: ContactAccessServiceProtocol {
    func requestPermission() async throws -> Bool {
        return true
    }
    
    func fetchContacts() async throws -> [ContactModel] {
        // Return mock contacts
        return [
            ContactModel(
                id: "1",
                name: "Ahmet Yılmaz",
                phoneNumbers: ["+905551234567"],
                emails: ["ahmet@example.com"]
            ),
            ContactModel(
                id: "2",
                name: "Ayşe Demir",
                phoneNumbers: ["+905559876543"],
                emails: ["ayse@example.com"]
            ),
            ContactModel(
                id: "3",
                name: "Mehmet Kaya",
                phoneNumbers: ["+905554567890"],
                emails: ["mehmet@example.com"]
            ),
            ContactModel(
                id: "4",
                name: "Fatma Öz",
                phoneNumbers: ["+905556789012"],
                emails: ["fatma@example.com"]
            ),
            ContactModel(
                id: "5",
                name: "Ali Çelik",
                phoneNumbers: ["+905558901234"],
                emails: ["ali@example.com"]
            )
        ]
    }
    
    func getPermissionStatus() -> CNAuthorizationStatus {
        return .authorized
    }
}

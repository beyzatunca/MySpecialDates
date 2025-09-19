import Foundation

// MARK: - ContactEntry Model
struct ContactEntry: Codable, Identifiable {
    let id: String
    let name: String
    let phoneNumber: String?
    let email: String?
    let isAppUser: Bool
    let matchedUserId: String?
    let syncedAt: Date
    
    init(id: String = UUID().uuidString, name: String, phoneNumber: String? = nil, email: String? = nil, isAppUser: Bool = false, matchedUserId: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.isAppUser = isAppUser
        self.matchedUserId = matchedUserId
        self.syncedAt = Date()
    }
}

// MARK: - BirthdayEntry Model
struct BirthdayEntry: Codable, Identifiable {
    let id: String
    let contactName: String
    let contactId: String
    let birthday: Date
    let type: BirthdayType
    let isFromContact: Bool
    let createdAt: Date
    
    enum BirthdayType: String, Codable, CaseIterable {
        case birthday = "birthday"
        case anniversary = "anniversary"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .birthday: return "Doğum Günü"
            case .anniversary: return "Yıldönümü"
            case .custom: return "Özel Gün"
            }
        }
    }
    
    init(id: String = UUID().uuidString, contactName: String, contactId: String, birthday: Date, type: BirthdayType = .birthday, isFromContact: Bool = true) {
        self.id = id
        self.contactName = contactName
        self.contactId = contactId
        self.birthday = birthday
        self.type = type
        self.isFromContact = isFromContact
        self.createdAt = Date()
    }
}

// MARK: - FirebaseUserModel (Extended User Model for Firestore)
struct FirebaseUserModel: Codable, Identifiable {
    let id: String
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let birthDate: Date?
    let profileImageURL: String?
    let isBirthdayPublic: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: String = UUID().uuidString,
         uid: String,
         firstName: String,
         lastName: String,
         email: String,
         phoneNumber: String? = nil,
         birthDate: Date? = nil,
         profileImageURL: String? = nil,
         isBirthdayPublic: Bool = true) {
        self.id = id
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.profileImageURL = profileImageURL
        self.isBirthdayPublic = isBirthdayPublic
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - ContactModel (for iOS Contacts framework)
struct ContactModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let phoneNumbers: [String]
    let emails: [String]
    
    init(id: String, name: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.id = id
        self.name = name
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
    var primaryPhone: String? {
        phoneNumbers.first
    }
    
    var primaryEmail: String? {
        emails.first
    }
}

// MARK: - Birthday Display Model
struct BirthdayDisplayModel: Identifiable, Hashable {
    let id = UUID()
    let contactName: String
    let birthday: Date
    let type: BirthdayEntry.BirthdayType
    let contactId: String
    let isFromContact: Bool
    
    var nextBirthday: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = birthdayComponents.month
        nextBirthdayComponents.day = birthdayComponents.day
        
        let nextBirthday = calendar.date(from: nextBirthdayComponents) ?? birthday
        
        // Eğer bu yılki doğum günü geçmişse, gelecek yıl
        if nextBirthday < Date() {
            var nextYearComponents = nextBirthdayComponents
            nextYearComponents.year = currentYear + 1
            return calendar.date(from: nextYearComponents) ?? birthday
        }
        
        return nextBirthday
    }
    
    var daysUntilBirthday: Int {
        let calendar = Calendar.current
        let today = Date()
        let next = nextBirthday
        return calendar.dateComponents([.day], from: today, to: next).day ?? 0
    }
    
    var age: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: birthday, to: Date()).year ?? 0
    }
}

// MARK: - Birthday Statistics Model
struct BirthdayStatistics {
    let totalBirthdays: Int
    let upcomingBirthdays: Int
    let thisMonthBirthdays: Int
    let fromContacts: Int
    let manual: Int
}

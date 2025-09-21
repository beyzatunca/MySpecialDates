import Foundation
// import FirebaseFirestoreSwift

// MARK: - User Model for Firestore
struct FirestoreUser: Codable, Identifiable {
    var id: String?
    let email: String
    let displayName: String
    let photoURL: String?
    let provider: String // "apple", "google", etc.
    let providerID: String
    let createdAt: Date
    let lastLoginAt: Date
    let isActive: Bool
    
    // Apple Sign-In specific fields
    let appleUserID: String?
    let realUserStatus: String? // "unsupported", "unknown", "likelyReal"
    
    init(
        id: String? = nil,
        email: String,
        displayName: String,
        photoURL: String? = nil,
        provider: String,
        providerID: String,
        appleUserID: String? = nil,
        realUserStatus: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.provider = provider
        self.providerID = providerID
        self.appleUserID = appleUserID
        self.realUserStatus = realUserStatus
        self.createdAt = Date()
        self.lastLoginAt = Date()
        self.isActive = true
    }
}

// MARK: - Event Model for Firestore
struct FirestoreEvent: Codable, Identifiable {
    var id: String?
    let userID: String // Reference to FirestoreUser.id
    let title: String
    let eventType: EventType
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let notes: String?
    let source: EventSource
    let sourceID: String? // Apple Calendar event ID, manual entry ID, etc.
    let createdAt: Date
    var updatedAt: Date
    var isActive: Bool
    
    // Birthday specific fields
    let isBirthday: Bool
    let birthdayPersonName: String?
    let birthdayYear: Int?
    
    // Manual entry specific fields
    let customIcon: String?
    let customColor: String?
    
    enum EventType: String, Codable, CaseIterable {
        case birthday = "birthday"
        case anniversary = "anniversary"
        case holiday = "holiday"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .birthday: return "Doğum Günü"
            case .anniversary: return "Yıldönümü"
            case .holiday: return "Bayram"
            case .custom: return "Özel Gün"
            }
        }
    }
    
    enum EventSource: String, Codable {
        case appleCalendar = "apple_calendar"
        case manual = "manual"
        case contact = "contact"
        case `import` = "import"
        
        var displayName: String {
            switch self {
            case .appleCalendar: return "Apple Takvim"
            case .manual: return "Manuel"
            case .contact: return "Kişi"
            case .import: return "İçe Aktarım"
            }
        }
    }
    
    init(
        id: String? = nil,
        userID: String,
        title: String,
        eventType: EventType,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = true,
        notes: String? = nil,
        source: EventSource,
        sourceID: String? = nil,
        isBirthday: Bool = false,
        birthdayPersonName: String? = nil,
        birthdayYear: Int? = nil,
        customIcon: String? = nil,
        customColor: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.title = title
        self.eventType = eventType
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.notes = notes
        self.source = source
        self.sourceID = sourceID
        self.isBirthday = isBirthday
        self.birthdayPersonName = birthdayPersonName
        self.birthdayYear = birthdayYear
        self.customIcon = customIcon
        self.customColor = customColor
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
    }
}

// MARK: - Calendar Sync Status Model
struct CalendarSyncStatus: Codable {
    let userID: String
    let lastSyncDate: Date
    let appleCalendarEnabled: Bool
    let totalEventsSynced: Int
    let lastError: String?
    let syncInProgress: Bool
    
    init(
        userID: String,
        lastSyncDate: Date = Date(),
        appleCalendarEnabled: Bool = false,
        totalEventsSynced: Int = 0,
        lastError: String? = nil,
        syncInProgress: Bool = false
    ) {
        self.userID = userID
        self.lastSyncDate = lastSyncDate
        self.appleCalendarEnabled = appleCalendarEnabled
        self.totalEventsSynced = totalEventsSynced
        self.lastError = lastError
        self.syncInProgress = syncInProgress
    }
}

// MARK: - Display Models for UI
struct EventDisplayModel: Identifiable {
    let id: String
    let title: String
    let eventType: FirestoreEvent.EventType
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let notes: String?
    let source: FirestoreEvent.EventSource
    let isBirthday: Bool
    let birthdayPersonName: String?
    let customIcon: String?
    let customColor: String?
    
    var displayName: String {
        if isBirthday, let personName = birthdayPersonName {
            return personName
        }
        return title
    }
    
    var icon: String {
        if let customIcon = customIcon {
            return customIcon
        }
        
        switch eventType {
        case .birthday: return "🎂"
        case .anniversary: return "💍"
        case .holiday: return "🎉"
        case .custom: return "⭐"
        }
    }
    
    var daysUntilEvent: Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Get this year's date for the event
        let eventThisYear = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: startDate),
            day: calendar.component(.day, from: startDate)
        )) ?? startDate
        
        // If the date has passed this year, use next year
        let eventDate = eventThisYear < today ? 
            calendar.date(byAdding: .year, value: 1, to: eventThisYear) ?? eventThisYear :
            eventThisYear
        
        return calendar.dateComponents([.day], from: today, to: eventDate).day ?? 0
    }
}

// MARK: - Extensions
extension FirestoreEvent {
    func toDisplayModel() -> EventDisplayModel {
        return EventDisplayModel(
            id: id ?? UUID().uuidString,
            title: title,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: notes,
            source: source,
            isBirthday: isBirthday,
            birthdayPersonName: birthdayPersonName,
            customIcon: customIcon,
            customColor: customColor
        )
    }
}

extension AppleCalendarEvent {
    func toFirestoreEvent(userID: String) -> FirestoreEvent {
        let eventType: FirestoreEvent.EventType = isBirthday ? .birthday : .custom
        
        return FirestoreEvent(
            userID: userID,
            title: title,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: notes,
            source: .appleCalendar,
            sourceID: id,
            isBirthday: isBirthday,
            birthdayPersonName: isBirthday ? displayName : nil
        )
    }
}

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let date: Date
    let eventType: EventType
    let isRecurring: Bool
    let reminderDays: [Int] // Days before event to remind (e.g., [1, 7, 30])
    let isCalendarEvent: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum EventType: String, Codable, CaseIterable {
        case birthday = "birthday"
        case anniversary = "anniversary"
        case custom = "custom"
        case holiday = "holiday"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .birthday: return "Doğum Günü"
            case .anniversary: return "Yıl Dönümü"
            case .custom: return "Özel Gün"
            case .holiday: return "Tatil"
            case .other: return "Diğer"
            }
        }
        
        var icon: String {
            switch self {
            case .birthday: return "gift"
            case .anniversary: return "heart"
            case .custom: return "star"
            case .holiday: return "calendar"
            case .other: return "circle"
            }
        }
        
        var color: String {
            switch self {
            case .birthday: return "pink"
            case .anniversary: return "red"
            case .custom: return "blue"
            case .holiday: return "green"
            case .other: return "gray"
            }
        }
    }
    
    // Computed properties
    var daysUntilEvent: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDate = calendar.startOfDay(for: date)
        
        // For recurring events, calculate next occurrence
        let nextOccurrence = getNextOccurrence()
        let nextDate = calendar.startOfDay(for: nextOccurrence)
        
        return calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
    }
    
    var isToday: Bool {
        daysUntilEvent == 0
    }
    
    var isUpcoming: Bool {
        daysUntilEvent > 0 && daysUntilEvent <= 30
    }
    
    var age: Int? {
        guard eventType == .birthday else { return nil }
        return Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }
    
    var yearsOfAnniversary: Int? {
        guard eventType == .anniversary else { return nil }
        return Calendar.current.dateComponents([.year], from: date, to: Date()).year
    }
    
    // MARK: - Initialization
    init(id: String = UUID().uuidString,
         title: String,
         description: String? = nil,
         date: Date,
         eventType: EventType,
         isRecurring: Bool = true,
         reminderDays: [Int] = [1, 7],
         isCalendarEvent: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.eventType = eventType
        self.isRecurring = isRecurring
        self.reminderDays = reminderDays
        self.isCalendarEvent = isCalendarEvent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Helper Methods
    private func getNextOccurrence() -> Date {
        guard isRecurring else { return date }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get the next occurrence of this event
        var nextDate = date
        while nextDate < today {
            nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
        }
        
        return nextDate
    }
}

// MARK: - Event Extensions
extension Event {
    static var mock: Event {
        Event(
            title: "John Doe Doğum Günü",
            description: "En yakın arkadaşımın doğum günü",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            eventType: .birthday
        )
    }
    
    static var mockAnniversary: Event {
        Event(
            title: "Evlilik Yıl Dönümü",
            description: "Anne ve babamın evlilik yıl dönümü",
            date: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
            eventType: .anniversary
        )
    }
}

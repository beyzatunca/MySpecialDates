import Foundation
import EventKit
import Combine

// MARK: - Apple Calendar Event Model
struct AppleCalendarEvent {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let notes: String?
    let url: URL?
    let calendarTitle: String
    let isBirthday: Bool
    
    var displayName: String {
        // Extract name from birthday title (e.g., "John's Birthday" -> "John")
        if isBirthday && title.lowercased().contains("birthday") {
            return title.replacingOccurrences(of: "'s Birthday", with: "", options: .caseInsensitive)
                       .replacingOccurrences(of: " Birthday", with: "", options: .caseInsensitive)
                       .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return title
    }
}

// MARK: - Calendar Access Error
enum CalendarAccessError: Error, LocalizedError {
    case accessDenied
    case accessRestricted
    case accessNotDetermined
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Takvim erişimi reddedildi"
        case .accessRestricted:
            return "Takvim erişimi kısıtlandı"
        case .accessNotDetermined:
            return "Takvim erişimi henüz belirlenmedi"
        case .unknown(let message):
            return "Bilinmeyen hata: \(message)"
        }
    }
}

// MARK: - Apple Calendar Service Protocol
protocol AppleCalendarServiceProtocol {
    func requestCalendarAccess() async throws -> Bool
    func getCalendarPermissionStatus() -> EKAuthorizationStatus
    func fetchBirthdayEvents() async throws -> [AppleCalendarEvent]
    func fetchAllEvents() async throws -> [AppleCalendarEvent]
}

// MARK: - Apple Calendar Service Implementation
@MainActor
class AppleCalendarService: ObservableObject, AppleCalendarServiceProtocol {
    private let eventStore = EKEventStore()
    @Published var permissionStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        Task { @MainActor in
            permissionStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    // MARK: - Permission Management
    
    func requestCalendarAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            permissionStatus = .authorized
            return true
            
        case .denied, .restricted:
            permissionStatus = status
            throw CalendarAccessError.accessDenied
            
        case .notDetermined:
            let granted = try await eventStore.requestFullAccessToEvents()
            permissionStatus = EKEventStore.authorizationStatus(for: .event)
            return granted
            
        @unknown default:
            permissionStatus = .denied
            throw CalendarAccessError.unknown("Unknown authorization status")
        }
    }
    
    func getCalendarPermissionStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - Event Fetching
    
    func fetchBirthdayEvents() async throws -> [AppleCalendarEvent] {
        guard permissionStatus == .authorized else {
            throw CalendarAccessError.accessDenied
        }
        
        let calendars = eventStore.calendars(for: .event)
        let birthdayCalendars = calendars.filter { calendar in
            calendar.title.lowercased().contains("birthday") ||
            calendar.title.lowercased().contains("doğum") ||
            calendar.type == .birthday
        }
        
        guard !birthdayCalendars.isEmpty else {
            return []
        }
        
        // Fetch events from the last year to next year
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        let endDate = calendar.date(byAdding: .year, value: 1, to: now) ?? now
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: birthdayCalendars
        )
        
        let events = eventStore.events(matching: predicate)
        
        return events.compactMap { event in
            // Filter for birthday events
            let title = event.title?.lowercased() ?? ""
            let isBirthday = title.contains("birthday") || 
                           title.contains("doğum") ||
                           event.calendar.type == .birthday
            
            guard isBirthday else { return nil }
            
            return AppleCalendarEvent(
                id: event.eventIdentifier,
                title: event.title ?? "",
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                notes: event.notes,
                url: event.url,
                calendarTitle: event.calendar.title,
                isBirthday: true
            )
        }
    }
    
    func fetchAllEvents() async throws -> [AppleCalendarEvent] {
        guard permissionStatus == .authorized else {
            throw CalendarAccessError.accessDenied
        }
        
        let calendars = eventStore.calendars(for: .event)
        
        // Fetch events from the last year to next year
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        let endDate = calendar.date(byAdding: .year, value: 1, to: now) ?? now
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        let events = eventStore.events(matching: predicate)
        
        return events.compactMap { event in
            let title = event.title?.lowercased() ?? ""
            let isBirthday = title.contains("birthday") || 
                           title.contains("doğum") ||
                           event.calendar.type == .birthday
            
            return AppleCalendarEvent(
                id: event.eventIdentifier,
                title: event.title ?? "",
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                notes: event.notes,
                url: event.url,
                calendarTitle: event.calendar.title,
                isBirthday: isBirthday
            )
        }
    }
}

// MARK: - Mock Apple Calendar Service (for testing)
class MockAppleCalendarService: AppleCalendarServiceProtocol {
    func requestCalendarAccess() async throws -> Bool {
        // Simulate permission granted
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        return true
    }
    
    func getCalendarPermissionStatus() -> EKAuthorizationStatus {
        return .authorized
    }
    
    func fetchBirthdayEvents() async throws -> [AppleCalendarEvent] {
        // Mock birthday events
        let calendar = Calendar.current
        let today = Date()
        
        return [
            AppleCalendarEvent(
                id: "mock-1",
                title: "John's Birthday",
                startDate: today,
                endDate: today,
                isAllDay: true,
                notes: "John's birthday",
                url: nil,
                calendarTitle: "Birthdays",
                isBirthday: true
            ),
            AppleCalendarEvent(
                id: "mock-2",
                title: "Sarah's Birthday",
                startDate: calendar.date(byAdding: .day, value: 5, to: today) ?? today,
                endDate: calendar.date(byAdding: .day, value: 5, to: today) ?? today,
                isAllDay: true,
                notes: "Sarah's birthday",
                url: nil,
                calendarTitle: "Birthdays",
                isBirthday: true
            )
        ]
    }
    
    func fetchAllEvents() async throws -> [AppleCalendarEvent] {
        return try await fetchBirthdayEvents()
    }
}

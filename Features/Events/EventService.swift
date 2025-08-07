import Foundation
import Combine

enum EventError: Error, LocalizedError {
    case invalidTitle
    case invalidDate
    case eventNotFound
    case saveFailed
    case deleteFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Geçersiz başlık"
        case .invalidDate:
            return "Geçersiz tarih"
        case .eventNotFound:
            return "Etkinlik bulunamadı"
        case .saveFailed:
            return "Kaydetme başarısız"
        case .deleteFailed:
            return "Silme başarısız"
        case .unknown:
            return "Bilinmeyen hata"
        }
    }
}

protocol EventServiceProtocol {
    func createEvent(title: String, description: String?, date: Date, eventType: Event.EventType, isRecurring: Bool, reminderDays: [Int], isCalendarEvent: Bool) async throws -> Event
    func getEvents() async throws -> [Event]
    func getEvents(for type: Event.EventType) async throws -> [Event]
    func getUpcomingEvents(limit: Int) async throws -> [Event]
    func getEventsForDate(_ date: Date) async throws -> [Event]
    func updateEvent(_ event: Event) async throws
    func deleteEvent(_ event: Event) async throws
}

class EventService: EventServiceProtocol {
    private let eventRepository: EventRepositoryProtocol
    
    init(eventRepository: EventRepositoryProtocol = EventRepository()) {
        self.eventRepository = eventRepository
    }
    
    // MARK: - Create Event
    func createEvent(title: String, description: String?, date: Date, eventType: Event.EventType, isRecurring: Bool, reminderDays: [Int], isCalendarEvent: Bool) async throws -> Event {
        
        // Validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw EventError.invalidTitle
        }
        
        guard date > Date().addingTimeInterval(-86400) else { // Allow events from yesterday
            throw EventError.invalidDate
        }
        
        // Create event
        let event = Event(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description?.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            eventType: eventType,
            isRecurring: isRecurring,
            reminderDays: reminderDays,
            isCalendarEvent: isCalendarEvent
        )
        
        // Save event
        try await eventRepository.saveEvent(event)
        
        // TODO: Add to calendar if isCalendarEvent is true
        if isCalendarEvent {
            // await addToCalendar(event)
        }
        
        return event
    }
    
    // MARK: - Get Events
    func getEvents() async throws -> [Event] {
        return try await eventRepository.getEvents()
    }
    
    func getEvents(for type: Event.EventType) async throws -> [Event] {
        return try await eventRepository.getEvents(for: type)
    }
    
    func getUpcomingEvents(limit: Int = 10) async throws -> [Event] {
        return try await eventRepository.getUpcomingEvents(limit: limit)
    }
    
    func getEventsForDate(_ date: Date) async throws -> [Event] {
        return try await eventRepository.getEventsForDate(date)
    }
    
    // MARK: - Update Event
    func updateEvent(_ event: Event) async throws {
        try await eventRepository.updateEvent(event)
        
        // TODO: Update calendar event if needed
        if event.isCalendarEvent {
            // await updateCalendarEvent(event)
        }
    }
    
    // MARK: - Delete Event
    func deleteEvent(_ event: Event) async throws {
        try await eventRepository.deleteEvent(event)
        
        // TODO: Remove from calendar if needed
        if event.isCalendarEvent {
            // await removeFromCalendar(event)
        }
    }
}

// MARK: - Calendar Integration (TODO)
extension EventService {
    private func addToCalendar(_ event: Event) async {
        // TODO: Implement calendar integration
        print("Adding event to calendar: \(event.title)")
    }
    
    private func updateCalendarEvent(_ event: Event) async {
        // TODO: Implement calendar update
        print("Updating calendar event: \(event.title)")
    }
    
    private func removeFromCalendar(_ event: Event) async {
        // TODO: Implement calendar removal
        print("Removing event from calendar: \(event.title)")
    }
}

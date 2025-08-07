import Foundation
import Combine

protocol EventRepositoryProtocol {
    func saveEvent(_ event: Event) async throws
    func getEvents() async throws -> [Event]
    func getEvents(for type: Event.EventType) async throws -> [Event]
    func getUpcomingEvents(limit: Int) async throws -> [Event]
    func getEventsForDate(_ date: Date) async throws -> [Event]
    func updateEvent(_ event: Event) async throws
    func deleteEvent(_ event: Event) async throws
}

class EventRepository: EventRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let eventsKey = "saved_events"
    
    // MARK: - Save Event
    func saveEvent(_ event: Event) async throws {
        var events = getAllEvents()
        events[event.id] = event
        saveAllEvents(events)
    }
    
    // MARK: - Get All Events
    func getEvents() async throws -> [Event] {
        let events = getAllEvents()
        return Array(events.values).sorted { $0.date < $1.date }
    }
    
    // MARK: - Get Events by Type
    func getEvents(for type: Event.EventType) async throws -> [Event] {
        let events = getAllEvents()
        return Array(events.values)
            .filter { $0.eventType == type }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Get Upcoming Events
    func getUpcomingEvents(limit: Int = 10) async throws -> [Event] {
        let events = getAllEvents()
        return Array(events.values)
            .filter { $0.isUpcoming }
            .sorted { $0.daysUntilEvent < $1.daysUntilEvent }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Get Events for Specific Date
    func getEventsForDate(_ date: Date) async throws -> [Event] {
        let events = getAllEvents()
        let calendar = Calendar.current
        
        return Array(events.values).filter { event in
            let eventDate = calendar.startOfDay(for: event.date)
            let targetDate = calendar.startOfDay(for: date)
            
            // For recurring events, check if they occur on this date
            if event.isRecurring {
                let eventMonth = calendar.component(.month, from: eventDate)
                let eventDay = calendar.component(.day, from: eventDate)
                let targetMonth = calendar.component(.month, from: targetDate)
                let targetDay = calendar.component(.day, from: targetDate)
                
                return eventMonth == targetMonth && eventDay == targetDay
            } else {
                return eventDate == targetDate
            }
        }
    }
    
    // MARK: - Update Event
    func updateEvent(_ event: Event) async throws {
        var events = getAllEvents()
        events[event.id] = event
        saveAllEvents(events)
    }
    
    // MARK: - Delete Event
    func deleteEvent(_ event: Event) async throws {
        var events = getAllEvents()
        events.removeValue(forKey: event.id)
        saveAllEvents(events)
    }
    
    // MARK: - Private Helper Methods
    private func getAllEvents() -> [String: Event] {
        guard let data = userDefaults.data(forKey: eventsKey),
              let events = try? JSONDecoder().decode([String: Event].self, from: data) else {
            return [:]
        }
        return events
    }
    
    private func saveAllEvents(_ events: [String: Event]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        userDefaults.set(data, forKey: eventsKey)
    }
}

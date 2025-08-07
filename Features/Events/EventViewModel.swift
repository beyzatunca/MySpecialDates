import Foundation
import Combine
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var upcomingEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // Form fields for creating/editing events
    @Published var title = ""
    @Published var description = ""
    @Published var date = Date()
    @Published var eventType: Event.EventType = .birthday
    @Published var isRecurring = true
    @Published var reminderDays: [Int] = [1, 7]
    @Published var isCalendarEvent = true
    
    // UI State
    @Published var showingAddEvent = false
    @Published var showingEventDetail = false
    @Published var selectedEvent: Event?
    @Published var selectedDate = Date()
    
    private let eventService: EventServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(eventService: EventServiceProtocol = EventService()) {
        self.eventService = eventService
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Auto-refresh events when needed
        $selectedDate
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadEventsForSelectedDate()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Events
    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await eventService.getEvents()
            upcomingEvents = try await eventService.getUpcomingEvents(limit: 5)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    func loadEventsForSelectedDate() async {
        do {
            let eventsForDate = try await eventService.getEventsForDate(selectedDate)
            // Update events for the selected date
            // This could be used in a calendar view
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    // MARK: - Create Event
    func createEvent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let event = try await eventService.createEvent(
                title: title,
                description: description.isEmpty ? nil : description,
                date: date,
                eventType: eventType,
                isRecurring: isRecurring,
                reminderDays: reminderDays,
                isCalendarEvent: isCalendarEvent
            )
            
            events.append(event)
            await loadEvents() // Refresh the list
            
            clearForm()
            showingAddEvent = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Event
    func updateEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedEvent = Event(
                id: event.id,
                title: title,
                description: description.isEmpty ? nil : description,
                date: date,
                eventType: eventType,
                isRecurring: isRecurring,
                reminderDays: reminderDays,
                isCalendarEvent: isCalendarEvent,
                createdAt: event.createdAt,
                updatedAt: Date()
            )
            
            try await eventService.updateEvent(updatedEvent)
            
            if let index = events.firstIndex(where: { $0.id == event.id }) {
                events[index] = updatedEvent
            }
            
            clearForm()
            showingAddEvent = false
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Event
    func deleteEvent(_ event: Event) async {
        do {
            try await eventService.deleteEvent(event)
            events.removeAll { $0.id == event.id }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    // MARK: - Edit Event
    func editEvent(_ event: Event) {
        selectedEvent = event
        title = event.title
        description = event.description ?? ""
        date = event.date
        eventType = event.eventType
        isRecurring = event.isRecurring
        reminderDays = event.reminderDays
        isCalendarEvent = event.isCalendarEvent
        showingAddEvent = true
    }
    
    // MARK: - Helper Methods
    private func clearForm() {
        title = ""
        description = ""
        date = Date()
        eventType = .birthday
        isRecurring = true
        reminderDays = [1, 7]
        isCalendarEvent = true
        selectedEvent = nil
    }
    
    func dismissError() {
        errorMessage = nil
        showingError = false
    }
    
    // MARK: - Filter Methods
    func getEvents(for type: Event.EventType) -> [Event] {
        return events.filter { $0.eventType == type }
    }
    
    func getTodayEvents() -> [Event] {
        return events.filter { $0.isToday }
    }
    
    func getUpcomingEvents(limit: Int = 5) -> [Event] {
        return events.filter { $0.isUpcoming }
            .sorted { $0.daysUntilEvent < $1.daysUntilEvent }
            .prefix(limit)
            .map { $0 }
    }
}

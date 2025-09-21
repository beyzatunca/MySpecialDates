import Foundation
import Combine

// MARK: - Firebase Event Service Protocol
protocol FirebaseEventServiceProtocol {
    func saveUser(_ user: FirestoreUser) async throws
    func getCurrentUser() async throws -> FirestoreUser?
    func updateUser(_ user: FirestoreUser) async throws
    
    func saveEvent(_ event: FirestoreEvent) async throws
    func getUserEvents(userID: String) async throws -> [FirestoreEvent]
    func deleteEvent(_ eventID: String, userID: String) async throws
    func updateEvent(_ event: FirestoreEvent) async throws
    
    func syncAppleCalendarEvents(_ events: [AppleCalendarEvent], userID: String) async throws -> Int
    func getSyncStatus(userID: String) async throws -> CalendarSyncStatus?
    func updateSyncStatus(_ status: CalendarSyncStatus) async throws
}

// MARK: - Mock Firebase Event Service (for testing without Firebase)
@MainActor
class FirebaseEventService: ObservableObject, FirebaseEventServiceProtocol {
    private var mockUsers: [String: FirestoreUser] = [:]
    private var mockEvents: [String: FirestoreEvent] = [:]
    private var mockSyncStatus: [String: CalendarSyncStatus] = [:]
    
    // MARK: - User Management
    
    func saveUser(_ user: FirestoreUser) async throws {
        guard let userID = user.id else {
            throw FirebaseError.invalidUserID
        }
        
        mockUsers[userID] = user
        print("✅ Mock: Kullanıcı kaydedildi: \(user.displayName)")
    }
    
    func getCurrentUser() async throws -> FirestoreUser? {
        // Mock: Return mock user
        let mockUser = FirestoreUser(
            id: "mock-user-id", // ID'yi açıkça set et
            email: "test@example.com",
            displayName: "Test User",
            provider: "apple.com",
            providerID: "mock-user-id",
            appleUserID: "mock-apple-id"
        )
        return mockUser
    }
    
    func updateUser(_ user: FirestoreUser) async throws {
        guard let userID = user.id else {
            throw FirebaseError.invalidUserID
        }
        
        mockUsers[userID] = user
        print("✅ Mock: Kullanıcı güncellendi: \(user.displayName)")
    }
    
    // MARK: - Event Management
    
    func saveEvent(_ event: FirestoreEvent) async throws {
        let eventID = event.id ?? UUID().uuidString
        var newEvent = event
        newEvent.id = eventID
        mockEvents[eventID] = newEvent
        print("✅ Mock: Etkinlik kaydedildi: \(event.title)")
    }
    
    func getUserEvents(userID: String) async throws -> [FirestoreEvent] {
        return mockEvents.values.filter { $0.userID == userID && $0.isActive }
    }
    
    func deleteEvent(_ eventID: String, userID: String) async throws {
        if var event = mockEvents[eventID] {
            event.isActive = false
            event.updatedAt = Date()
            mockEvents[eventID] = event
        }
        print("✅ Mock: Etkinlik silindi: \(eventID)")
    }
    
    func updateEvent(_ event: FirestoreEvent) async throws {
        guard let eventID = event.id else {
            throw FirebaseError.invalidEventID
        }
        mockEvents[eventID] = event
        print("✅ Mock: Etkinlik güncellendi: \(event.title)")
    }
    
    // MARK: - Apple Calendar Sync
    
    func syncAppleCalendarEvents(_ events: [AppleCalendarEvent], userID: String) async throws -> Int {
        var syncedCount = 0
        
        for appleEvent in events {
            let firestoreEvent = appleEvent.toFirestoreEvent(userID: userID)
            try await saveEvent(firestoreEvent)
            syncedCount += 1
        }
        
        let syncStatus = CalendarSyncStatus(
            userID: userID,
            lastSyncDate: Date(),
            appleCalendarEnabled: true,
            totalEventsSynced: syncedCount,
            lastError: nil,
            syncInProgress: false
        )
        
        try await updateSyncStatus(syncStatus)
        
        print("✅ Mock: Apple Takvim senkronizasyonu tamamlandı: \(syncedCount) etkinlik")
        return syncedCount
    }
    
    func getSyncStatus(userID: String) async throws -> CalendarSyncStatus? {
        return mockSyncStatus[userID]
    }
    
    func updateSyncStatus(_ status: CalendarSyncStatus) async throws {
        mockSyncStatus[status.userID] = status
        print("✅ Mock: Senkronizasyon durumu güncellendi")
    }
}

// MARK: - Firebase Error
enum FirebaseError: Error, LocalizedError {
    case invalidUserID
    case invalidEventID
    case userNotFound
    case eventNotFound
    case networkError(String)
    case permissionDenied
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUserID:
            return "Geçersiz kullanıcı ID"
        case .invalidEventID:
            return "Geçersiz etkinlik ID"
        case .userNotFound:
            return "Kullanıcı bulunamadı"
        case .eventNotFound:
            return "Etkinlik bulunamadı"
        case .networkError(let message):
            return "Ağ hatası: \(message)"
        case .permissionDenied:
            return "İzin reddedildi"
        case .unknown(let message):
            return "Bilinmeyen hata: \(message)"
        }
    }
}
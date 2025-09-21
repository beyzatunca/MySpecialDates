import Foundation
import Combine
import EventKit
import AuthenticationServices

// MARK: - Calendar Sync State
enum CalendarSyncState {
    case idle
    case requestingPermissions
    case syncing
    case completed(Int) // Number of events synced
    case failed(Error)
}

// MARK: - Calendar Sync ViewModel
@MainActor
class CalendarSyncViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var syncState: CalendarSyncState = .idle
    @Published var isAuthenticated = false
    @Published var currentUser: FirestoreUser?
    @Published var userEvents: [EventDisplayModel] = []
    @Published var calendarPermissionStatus: EKAuthorizationStatus = .notDetermined
    @Published var syncStatus: CalendarSyncStatus?
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let appleCalendarService: AppleCalendarServiceProtocol
    private let appleSignInService: AppleSignInServiceProtocol
    private let firebaseService: FirebaseEventServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        appleCalendarService: AppleCalendarServiceProtocol? = nil,
        appleSignInService: AppleSignInServiceProtocol? = nil,
        firebaseService: FirebaseEventServiceProtocol? = nil
    ) {
        self.appleCalendarService = appleCalendarService ?? AppleCalendarService()
        self.appleSignInService = appleSignInService ?? AppleSignInService(firebaseService: FirebaseEventService())
        self.firebaseService = firebaseService ?? FirebaseEventService()
        
        setupBindings()
        checkInitialState()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Monitor authentication state
        $isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.loadUserData()
                } else {
                    self?.clearUserData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkInitialState() {
        Task {
            // Check authentication status
            if let user = appleSignInService.getCurrentUser() {
                currentUser = user
                isAuthenticated = true
            }
            
            // Check calendar permission status
            calendarPermissionStatus = appleCalendarService.getCalendarPermissionStatus()
        }
    }
    
    // MARK: - Authentication
    
    func signInWithApple() async {
        do {
            let user = try await appleSignInService.signInWithApple()
            currentUser = user
            isAuthenticated = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Apple Sign-In hatası: \(error)")
        }
    }
    
    func signOut() async {
        do {
            try await appleSignInService.signOut()
            currentUser = nil
            isAuthenticated = false
            clearUserData()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Çıkış hatası: \(error)")
        }
    }
    
    // MARK: - Calendar Permissions
    
    func requestCalendarPermission() async {
        syncState = .requestingPermissions
        
        do {
            let granted = try await appleCalendarService.requestCalendarAccess()
            calendarPermissionStatus = appleCalendarService.getCalendarPermissionStatus()
            
            if granted {
                syncState = .idle
                print("✅ Takvim izni verildi")
            } else {
                syncState = .failed(CalendarAccessError.accessDenied)
                errorMessage = "Takvim erişimi reddedildi"
            }
        } catch {
            syncState = .failed(error)
            errorMessage = error.localizedDescription
            print("❌ Takvim izni hatası: \(error)")
        }
    }
    
    // MARK: - Calendar Sync
    
    func syncAppleCalendar() async {
        guard isAuthenticated, let userID = currentUser?.id else {
            errorMessage = "Önce giriş yapmanız gerekiyor"
            return
        }
        
        guard calendarPermissionStatus == .authorized else {
            await requestCalendarPermission()
            return
        }
        
        syncState = .syncing
        errorMessage = nil
        
        do {
            // Fetch Apple Calendar events
            let appleEvents = try await appleCalendarService.fetchBirthdayEvents()
            print("📅 Apple Takvim'den \(appleEvents.count) doğum günü etkinliği alındı")
            
            // Sync to Firebase
            let syncedCount = try await firebaseService.syncAppleCalendarEvents(appleEvents, userID: userID)
            
            // Update sync status
            if let syncStatus = try await firebaseService.getSyncStatus(userID: userID) {
                self.syncStatus = syncStatus
            }
            
            // Reload user events
            await loadUserEvents()
            
            syncState = .completed(syncedCount)
            print("✅ Takvim senkronizasyonu tamamlandı: \(syncedCount) etkinlik")
            
        } catch {
            syncState = .failed(error)
            errorMessage = error.localizedDescription
            print("❌ Takvim senkronizasyonu hatası: \(error)")
        }
    }
    
    // MARK: - Data Loading
    
    private func loadUserData() {
        Task {
            await loadUserEvents()
            await loadSyncStatus()
        }
    }
    
    private func loadUserEvents() async {
        guard let userID = currentUser?.id else { return }
        
        do {
            let events = try await firebaseService.getUserEvents(userID: userID)
            userEvents = events.map { $0.toDisplayModel() }
            print("📋 \(userEvents.count) kullanıcı etkinliği yüklendi")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Etkinlik yükleme hatası: \(error)")
        }
    }
    
    private func loadSyncStatus() async {
        guard let userID = currentUser?.id else { return }
        
        do {
            syncStatus = try await firebaseService.getSyncStatus(userID: userID)
        } catch {
            print("❌ Senkronizasyon durumu yükleme hatası: \(error)")
        }
    }
    
    private func clearUserData() {
        userEvents = []
        syncStatus = nil
        syncState = .idle
    }
    
    // MARK: - Event Management
    
    func addManualEvent(
        title: String,
        eventType: FirestoreEvent.EventType,
        date: Date,
        notes: String? = nil,
        customIcon: String? = nil,
        customColor: String? = nil
    ) async {
        guard let userID = currentUser?.id else {
            errorMessage = "Önce giriş yapmanız gerekiyor"
            return
        }
        
        do {
            let event = FirestoreEvent(
                userID: userID,
                title: title,
                eventType: eventType,
                startDate: date,
                endDate: date,
                isAllDay: true,
                notes: notes,
                source: .manual,
                customIcon: customIcon,
                customColor: customColor
            )
            
            try await firebaseService.saveEvent(event)
            await loadUserEvents()
            
            print("✅ Manuel etkinlik eklendi: \(title)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Manuel etkinlik ekleme hatası: \(error)")
        }
    }
    
    func deleteEvent(_ eventID: String) async {
        guard let userID = currentUser?.id else { return }
        
        do {
            try await firebaseService.deleteEvent(eventID, userID: userID)
            await loadUserEvents()
            print("✅ Etkinlik silindi: \(eventID)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Etkinlik silme hatası: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    func getTodayEvents() -> [EventDisplayModel] {
        let today = Date()
        let calendar = Calendar.current
        
        return userEvents.filter { event in
            let eventThisYear = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: today),
                month: calendar.component(.month, from: event.startDate),
                day: calendar.component(.day, from: event.startDate)
            )) ?? event.startDate
            
            return calendar.isDate(eventThisYear, inSameDayAs: today)
        }
    }
    
    func getUpcomingEvents(within days: Int = 7) -> [EventDisplayModel] {
        let today = Date()
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .day, value: days, to: today) ?? today
        
        return userEvents.filter { event in
            let eventThisYear = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: today),
                month: calendar.component(.month, from: event.startDate),
                day: calendar.component(.day, from: event.startDate)
            )) ?? event.startDate
            
            return eventThisYear > today && eventThisYear <= futureDate
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func getMonthlyEvents() -> [EventDisplayModel] {
        let today = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: today)
        
        return userEvents.filter { event in
            calendar.component(.month, from: event.startDate) == currentMonth
        }.sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - UI State Helpers
    
    var canSyncCalendar: Bool {
        return isAuthenticated && calendarPermissionStatus == .authorized
    }
    
    var needsCalendarPermission: Bool {
        return calendarPermissionStatus != .authorized
    }
    
    var syncInProgress: Bool {
        if case .syncing = syncState {
            return true
        }
        return false
    }
    
    var lastSyncDate: Date? {
        return syncStatus?.lastSyncDate
    }
    
    var totalSyncedEvents: Int {
        return syncStatus?.totalEventsSynced ?? 0
    }
}

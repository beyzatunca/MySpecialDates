import Foundation
import Combine
import UIKit
import Contacts

// MARK: - Contact Sync State
enum ContactSyncState {
    case idle
    case requestingPermission
    case fetchingContacts
    case syncingToFirestore
    case matchingUsers
    case completed
    case error(Error)
}

// MARK: - Contact Sync View Model
@MainActor
class ContactSyncViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var syncState: ContactSyncState = .idle
    @Published var contacts: [ContactEntry] = []
    @Published var birthdays: [BirthdayDisplayModel] = []
    @Published var statistics: BirthdayStatistics?
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // MARK: - Private Properties
    private let contactService: ContactAccessServiceProtocol
    private let firebaseRepository: FirebaseUserRepositoryProtocol
    private let birthdayManager: BirthdayManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isSyncing: Bool {
        switch syncState {
        case .requestingPermission, .fetchingContacts, .syncingToFirestore, .matchingUsers:
            return true
        default:
            return false
        }
    }
    
    var syncProgress: Double {
        switch syncState {
        case .idle:
            return 0.0
        case .requestingPermission:
            return 0.2
        case .fetchingContacts:
            return 0.4
        case .syncingToFirestore:
            return 0.6
        case .matchingUsers:
            return 0.8
        case .completed:
            return 1.0
        case .error:
            return 0.0
        }
    }
    
    var syncStatusText: String {
        switch syncState {
        case .idle:
            return "Kişileri senkronize etmeye hazır"
        case .requestingPermission:
            return "İzin isteniyor..."
        case .fetchingContacts:
            return "Kişiler getiriliyor..."
        case .syncingToFirestore:
            return "Firestore'a kaydediliyor..."
        case .matchingUsers:
            return "Kullanıcılar eşleştiriliyor..."
        case .completed:
            return "Senkronizasyon tamamlandı"
        case .error(let error):
            return "Hata: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Initialization
    init(
        contactService: ContactAccessServiceProtocol,
        firebaseRepository: FirebaseUserRepositoryProtocol,
        birthdayManager: BirthdayManagerProtocol
    ) {
        self.contactService = contactService
        self.firebaseRepository = firebaseRepository
        self.birthdayManager = birthdayManager
    }
    
    convenience init() {
        self.init(
            contactService: MockContactAccessServiceWithData(),
            firebaseRepository: MockFirebaseUserRepository(),
            birthdayManager: MockBirthdayManager()
        )
        
        setupErrorHandling()
        Task {
            await loadExistingData()
        }
    }
    
    // MARK: - Setup Methods
    private func setupErrorHandling() {
        $syncState
            .compactMap { state in
                if case .error(let error) = state {
                    return error.localizedDescription
                }
                return nil
            }
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        $errorMessage
            .map { $0 != nil }
            .assign(to: \.showingError, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func startContactSync() async {
        guard !isSyncing else { return }
        
        do {
            await performContactSync()
        } catch {
            syncState = .error(error)
        }
    }
    
    func refreshData() async {
        await loadExistingData()
    }
    
    func addManualBirthday(
        contactName: String,
        birthday: Date,
        type: BirthdayEntry.BirthdayType
    ) async {
        do {
            let userId = try getCurrentUserId()
            let contactId = UUID().uuidString
            
            // Create birthday entry manually
            let birthdayEntry = BirthdayEntry(
                contactName: contactName,
                contactId: contactId,
                birthday: birthday,
                type: type,
                isFromContact: false
            )
            try await firebaseRepository.addBirthday(birthdayEntry, for: userId)
            
            await refreshData()
        } catch {
            syncState = .error(error)
        }
    }
    
    func deleteBirthday(_ birthdayId: String) async {
        do {
            let userId = try getCurrentUserId()
            try await firebaseRepository.deleteBirthday(birthdayId, for: userId)
            await refreshData()
        } catch {
            syncState = .error(error)
        }
    }
    
    func dismissError() {
        errorMessage = nil
        showingError = false
        syncState = .idle
    }
    
    // MARK: - Private Methods
    private func performContactSync() async {
        do {
            // 1. İzin kontrolü ve alma
            syncState = .requestingPermission
            let hasPermission = try await contactService.requestPermission()
            guard hasPermission else {
                throw ContactAccessError.permissionDenied
            }
            
            // 2. Kişileri getir
            syncState = .fetchingContacts
            let deviceContacts = try await contactService.fetchContacts()
            
            // 3. ContactEntry'lere çevir
            let contactEntries = deviceContacts.map { contact in
                ContactEntry(
                    name: contact.name,
                    phoneNumber: contact.primaryPhone,
                    email: contact.primaryEmail
                )
            }
            
            // 4. Firestore'a kaydet
            syncState = .syncingToFirestore
            let userId = try getCurrentUserId()
            try await firebaseRepository.saveContacts(contactEntries, for: userId)
            
            // 5. Kullanıcı eşleştirme ve doğum günü sync
            syncState = .matchingUsers
            let result = try await birthdayManager.processContactSync(for: userId)
            
            // 6. UI'ı güncelle
            self.contacts = result.contacts
            await updateBirthdaysFromFirestore(userId: userId)
            await updateStatistics(userId: userId)
            
            syncState = .completed
            
        } catch {
            syncState = .error(error)
        }
    }
    
    private func loadExistingData() async {
        do {
            let userId = try getCurrentUserId()
            
            // Mevcut verileri yükle
            async let contactsTask = firebaseRepository.getContacts(for: userId)
            async let birthdaysTask = updateBirthdaysFromFirestore(userId: userId)
            async let statisticsTask = updateStatistics(userId: userId)
            
            contacts = try await contactsTask
            await birthdaysTask
            await statisticsTask
            
        } catch {
            syncState = .error(error)
        }
    }
    
    private func updateBirthdaysFromFirestore(userId: String) async {
        do {
            let birthdayEntries = try await firebaseRepository.getBirthdays(for: userId)
            birthdays = birthdayEntries.map { entry in
                BirthdayDisplayModel(
                    contactName: entry.contactName,
                    birthday: entry.birthday,
                    type: entry.type,
                    contactId: entry.contactId,
                    isFromContact: entry.isFromContact
                )
            }.sorted { $0.daysUntilBirthday < $1.daysUntilBirthday }
        } catch {
            // Hata durumunda mevcut birthdays'leri koru
        }
    }
    
    private func updateStatistics(userId: String) async {
        do {
            // Get statistics from birthday manager if available
            // Note: BirthdayManagerProtocol may not have getBirthdayStatistics method
            // This is a placeholder - implement based on actual protocol
            statistics = nil
        } catch {
            // İstatistik hatası kritik değil
        }
    }
    
    private func getCurrentUserId() throws -> String {
        // Mock user ID for now
        return "mock-user-id"
    }
    
    // MARK: - Permission Methods
    func checkPermissionStatus() -> CNAuthorizationStatus {
        return contactService.getPermissionStatus()
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Contact Sync View Model Extensions
extension ContactSyncViewModel {
    
    // MARK: - Filtering Methods
    func getBirthdaysForMonth(_ month: Int) -> [BirthdayDisplayModel] {
        return birthdays.filter { birthday in
            Calendar.current.component(.month, from: birthday.birthday) == month
        }
    }
    
    func getUpcomingBirthdays(within days: Int = 30) -> [BirthdayDisplayModel] {
        return birthdays.filter { birthday in
            birthday.daysUntilBirthday <= days && birthday.daysUntilBirthday >= 0
        }
    }
    
    func getTodayBirthdays() -> [BirthdayDisplayModel] {
        let today = Date()
        let calendar = Calendar.current
        return birthdays.filter { birthday in
            let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday.birthday)
            let todayComponents = calendar.dateComponents([.month, .day], from: today)
            return birthdayComponents.month == todayComponents.month && 
                   birthdayComponents.day == todayComponents.day
        }
    }
    
    // MARK: - Search Methods
    func searchContacts(by query: String) -> [ContactEntry] {
        guard !query.isEmpty else { return contacts }
        
        return contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(query) ||
            (contact.email?.localizedCaseInsensitiveContains(query) ?? false) ||
            (contact.phoneNumber?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    func searchBirthdays(by query: String) -> [BirthdayDisplayModel] {
        guard !query.isEmpty else { return birthdays }
        
        return birthdays.filter { birthday in
            birthday.contactName.localizedCaseInsensitiveContains(query)
        }
    }
}

import SwiftUI

// MARK: - Contacts List View
struct ContactsListView: View {
    @ObservedObject var viewModel: ContactSyncViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with sync info
                headerView
                
                // Contacts list
                contactsList
            }
            .navigationTitle("Kişiler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Kişi ara...")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            // Sync status
            HStack {
                Image(systemName: viewModel.isSyncing ? "arrow.clockwise" : "checkmark.circle")
                    .foregroundColor(viewModel.isSyncing ? .orange : .green)
                
                Text(viewModel.syncStatusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Statistics
            if let stats = viewModel.statistics {
                HStack(spacing: 20) {
                    StatItem(title: "Toplam Kişi", value: "\(viewModel.contacts.count)")
                    StatItem(title: "Uygulama Kullanıcısı", value: "\(stats.fromContacts)")
                    StatItem(title: "Eşleşme", value: "\(viewModel.contacts.filter { $0.isAppUser }.count)")
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Contacts List
    private var contactsList: some View {
        List {
            ForEach(filteredContacts) { contact in
                ContactRowView(contact: contact)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var filteredContacts: [ContactEntry] {
        if searchText.isEmpty {
            return viewModel.contacts
        } else {
            return viewModel.searchContacts(by: searchText)
        }
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Contact Row View
struct ContactRowView: View {
    let contact: ContactEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(contact.isAppUser ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    if contact.isAppUser {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Text(String(contact.name.prefix(1)).uppercased())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
            
            // Contact info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    if let email = contact.email {
                        Label(email, systemImage: "envelope")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let phone = contact.phoneNumber {
                        Label(phone, systemImage: "phone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(alignment: .trailing, spacing: 4) {
                if contact.isAppUser {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Uygulama Kullanıcısı")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                } else {
                    Text("Kayıtlı Değil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Senkronize: \(contact.syncedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - All Birthdays View
struct AllBirthdaysView: View {
    @ObservedObject var viewModel: ContactSyncViewModel
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(filteredBirthdays) { birthday in
                BirthdayRowView(birthday: birthday)
            }
        }
        .navigationTitle("Tüm Doğum Günleri")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Doğum günü ara...")
    }
    
    private var filteredBirthdays: [BirthdayDisplayModel] {
        if searchText.isEmpty {
            return viewModel.birthdays
        } else {
            return viewModel.searchBirthdays(by: searchText)
        }
    }
}

#Preview {
    ContactsListView(viewModel: ContactSyncViewModel())
}

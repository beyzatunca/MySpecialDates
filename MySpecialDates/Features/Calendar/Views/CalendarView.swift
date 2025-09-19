import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var viewModel = ContactSyncViewModel()
    @State private var selectedDate = Date()
    @State private var showingAddBirthday = false
    @State private var showingContacts = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with statistics
                headerView
                
                // Calendar content
                calendarContentView
                
                // Birthday list
                birthdayListView
            }
            .navigationTitle("Doğum Günleri")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kişiler") {
                        showingContacts = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBirthday = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Doğum günü ara...")
            .sheet(isPresented: $showingAddBirthday) {
                AddBirthdayView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingContacts) {
                ContactsListView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .alert("Hata", isPresented: $viewModel.showingError) {
                Button("Tamam") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "Bilinmeyen hata")
            }
        }
        .task {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            // Statistics cards
            if let stats = viewModel.statistics {
                HStack(spacing: 16) {
                    StatCard(
                        title: "Toplam",
                        value: "\(stats.totalBirthdays)",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Bu Ay",
                        value: "\(stats.thisMonthBirthdays)",
                        icon: "calendar.badge.clock",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Yaklaşan",
                        value: "\(stats.upcomingBirthdays)",
                        icon: "clock",
                        color: .green
                    )
                }
                .padding(.horizontal)
            }
            
            // Sync button
            syncButton
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Sync Button
    private var syncButton: some View {
        Button(action: {
            Task {
                await viewModel.startContactSync()
            }
        }) {
            HStack {
                if viewModel.isSyncing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                
                Text(viewModel.syncStatusText)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isSyncing)
        .padding(.horizontal)
        
        // Progress bar
        if viewModel.isSyncing {
            ProgressView(value: viewModel.syncProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Calendar Content View
    private var calendarContentView: some View {
        VStack(spacing: 16) {
            // Month picker
            MonthPickerView(selectedDate: $selectedDate)
            
            // Today's birthdays
            if !viewModel.getTodayBirthdays().isEmpty {
                todayBirthdaysSection
            }
            
            // Upcoming birthdays
            upcomingBirthdaysSection
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Today's Birthdays Section
    private var todayBirthdaysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
                Text("Bugün Doğum Günü")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ForEach(viewModel.getTodayBirthdays()) { birthday in
                BirthdayRowView(birthday: birthday)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Upcoming Birthdays Section
    private var upcomingBirthdaysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Yaklaşan Doğum Günleri")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            let upcomingBirthdays = searchText.isEmpty ? 
                viewModel.getUpcomingBirthdays() : 
                viewModel.searchBirthdays(by: searchText)
            
            if upcomingBirthdays.isEmpty {
                Text("Yaklaşan doğum günü yok")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(upcomingBirthdays.prefix(5)) { birthday in
                    BirthdayRowView(birthday: birthday)
                }
                
                if upcomingBirthdays.count > 5 {
                    NavigationLink("Tümünü Gör") {
                        AllBirthdaysView(viewModel: viewModel)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Birthday List View
    private var birthdayListView: some View {
        List {
            // Monthly birthdays
            ForEach(1...12, id: \.self) { month in
                let monthBirthdays = viewModel.getBirthdaysForMonth(month)
                if !monthBirthdays.isEmpty {
                    Section(header: Text(monthName(for: month))) {
                        ForEach(monthBirthdays) { birthday in
                            BirthdayRowView(birthday: birthday)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Helper Methods
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.monthSymbols[month - 1]
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Birthday Row View
struct BirthdayRowView: View {
    let birthday: BirthdayDisplayModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(birthday.contactName.prefix(1)).uppercased())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(birthday.contactName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(birthday.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Days until birthday
            VStack(alignment: .trailing, spacing: 4) {
                if birthday.daysUntilBirthday == 0 {
                    Text("Bugün!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                } else if birthday.daysUntilBirthday == 1 {
                    Text("Yarın")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else {
                    Text("\(birthday.daysUntilBirthday) gün")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Text("\(birthday.age + 1) yaş")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Month Picker View
struct MonthPickerView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

#Preview {
    CalendarView()
}

import SwiftUI

struct EventsListView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var showingAddEvent = false
    @State private var selectedFilter: Event.EventType?
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "Tümü", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        ForEach(Event.EventType.allCases, id: \.self) { type in
                            FilterButton(
                                title: type.displayName,
                                isSelected: selectedFilter == type
                            ) {
                                selectedFilter = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Events List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Yükleniyor...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Henüz etkinlik yok")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("İlk etkinliğinizi ekleyerek başlayın")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Etkinlik Ekle") {
                            showingAddEvent = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        // Today Events
                        if !todayEvents.isEmpty {
                            Section("Bugün") {
                                ForEach(todayEvents) { event in
                                    EventRowView(event: event) {
                                        viewModel.editEvent(event)
                                        showingAddEvent = true
                                    }
                                }
                            }
                        }
                        
                        // Upcoming Events
                        if !upcomingEvents.isEmpty {
                            Section("Yaklaşan") {
                                ForEach(upcomingEvents) { event in
                                    EventRowView(event: event) {
                                        viewModel.editEvent(event)
                                        showingAddEvent = true
                                    }
                                }
                            }
                        }
                        
                        // All Events
                        Section("Tüm Etkinlikler") {
                            ForEach(filteredEvents) { event in
                                EventRowView(event: event) {
                                    viewModel.editEvent(event)
                                    showingAddEvent = true
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let event = filteredEvents[index]
                                    Task {
                                        await viewModel.deleteEvent(event)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Etkinlikler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(viewModel: viewModel)
            }
            .alert("Hata", isPresented: $viewModel.showingError) {
                Button("Tamam") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "Bilinmeyen hata")
            }
            .task {
                await viewModel.loadEvents()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredEvents: [Event] {
        if let filter = selectedFilter {
            return viewModel.getEvents(for: filter)
        }
        return viewModel.events
    }
    
    private var todayEvents: [Event] {
        return filteredEvents.filter { $0.isToday }
    }
    
    private var upcomingEvents: [Event] {
        return filteredEvents.filter { $0.isUpcoming && !$0.isToday }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Event Icon
                Image(systemName: event.eventType.icon)
                    .font(.title2)
                    .foregroundColor(Color(event.eventType.color))
                    .frame(width: 40, height: 40)
                    .background(Color(event.eventType.color).opacity(0.1))
                    .cornerRadius(10)
                
                // Event Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(event.eventType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if event.isRecurring {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let description = event.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Days Until Event
                VStack(alignment: .trailing, spacing: 4) {
                    if event.isToday {
                        Text("BUGÜN")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(8)
                    } else if event.isUpcoming {
                        Text("\(event.daysUntilEvent) gün")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(event.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EventsListView()
}

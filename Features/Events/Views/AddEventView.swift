import SwiftUI

struct AddEventView: View {
    @ObservedObject var viewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section("Temel Bilgiler") {
                    TextField("Başlık", text: $viewModel.title)
                    
                    TextField("Açıklama (İsteğe bağlı)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Tarih", selection: $viewModel.date, displayedComponents: [.date])
                }
                
                // Event Type
                Section("Etkinlik Türü") {
                    Picker("Tür", selection: $viewModel.eventType) {
                        ForEach(Event.EventType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(Color(type.color))
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Recurring Settings
                Section("Tekrarlama") {
                    Toggle("Her yıl tekrarla", isOn: $viewModel.isRecurring)
                    
                    if viewModel.isRecurring {
                        Text("Bu etkinlik her yıl aynı tarihte tekrarlanacak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Reminder Settings
                Section("Hatırlatıcılar") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hatırlatma günleri:")
                            .font(.subheadline)
                        
                        ForEach([1, 3, 7, 14, 30], id: \.self) { day in
                            HStack {
                                Button(action: {
                                    if viewModel.reminderDays.contains(day) {
                                        viewModel.reminderDays.removeAll { $0 == day }
                                    } else {
                                        viewModel.reminderDays.append(day)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.reminderDays.contains(day) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.reminderDays.contains(day) ? .blue : .gray)
                                        
                                        Text("\(day) gün önce")
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Calendar Integration
                Section("Takvim") {
                    Toggle("Takvime ekle", isOn: $viewModel.isCalendarEvent)
                    
                    if viewModel.isCalendarEvent {
                        Text("Bu etkinlik telefon takviminize eklenecek")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Preview
                if !viewModel.title.isEmpty {
                    Section("Önizleme") {
                        EventPreviewCard(event: Event(
                            title: viewModel.title,
                            description: viewModel.description.isEmpty ? nil : viewModel.description,
                            date: viewModel.date,
                            eventType: viewModel.eventType,
                            isRecurring: viewModel.isRecurring,
                            reminderDays: viewModel.reminderDays,
                            isCalendarEvent: viewModel.isCalendarEvent
                        ))
                    }
                }
            }
            .navigationTitle(viewModel.selectedEvent != nil ? "Etkinliği Düzenle" : "Yeni Etkinlik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.selectedEvent != nil ? "Güncelle" : "Ekle") {
                        Task {
                            if let selectedEvent = viewModel.selectedEvent {
                                await viewModel.updateEvent(selectedEvent)
                            } else {
                                await viewModel.createEvent()
                            }
                            dismiss()
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

// MARK: - Event Preview Card
struct EventPreviewCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.eventType.icon)
                    .font(.title2)
                    .foregroundColor(Color(event.eventType.color))
                    .frame(width: 40, height: 40)
                    .background(Color(event.eventType.color).opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    
                    Text(event.eventType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
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
            
            if let description = event.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if event.isRecurring {
                    Label("Yıllık", systemImage: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if event.isCalendarEvent {
                    Label("Takvim", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(event.reminderDays.count) hatırlatıcı")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AddEventView(viewModel: EventViewModel())
}

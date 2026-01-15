//
//  AddSpecialDayView.swift
//  MySpecialDates
//
//  Created by Beyza Erdemli on 17.09.2025.
//

import SwiftUI
import PhotosUI

struct AddSpecialDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userEvents: [UserEvent]
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedType: EventType? = nil
    @State private var showingCalendar = false
    @State private var showingCustomOccasionInput = false
    @State private var customOccasionName = ""
    @State private var selectedDate = Date()
    @State private var showingIconSelector = false
    @State private var selectedIcon = "🎉"
    @State private var dateSelected = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var eventPhoto: UIImage? = nil
    
    init(userEvents: Binding<[UserEvent]> = .constant([])) {
        self._userEvents = userEvents
    }
    
    enum EventType: CaseIterable {
        case birthday
        case anniversary
        case graduation
        case wedding
        case custom
        
        var title: String {
            switch self {
            case .birthday: return "Birthday"
            case .anniversary: return "Anniversary"
            case .graduation: return "Graduation"
            case .wedding: return "Wedding"
            case .custom: return "Your Own Occasion"
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .birthday: return "🎂"
            case .anniversary: return "💍"
            case .graduation: return "🎓"
            case .wedding: return "💒"
            case .custom: return "🎉"
            }
        }
        
        var icon: String {
            switch self {
            case .birthday: return "birthday.cake.fill"
            case .anniversary: return "heart.fill"
            case .graduation: return "graduationcap.fill"
            case .wedding: return "heart.circle.fill"
            case .custom: return "sparkles"
            }
        }
        
        var color: Color {
            switch self {
            case .birthday: return Color(red: 1.0, green: 0.6, blue: 0.7)
            case .anniversary: return Color(red: 0.9, green: 0.4, blue: 0.6)
            case .graduation: return Color(red: 0.4, green: 0.6, blue: 0.9)
            case .wedding: return Color(red: 0.95, green: 0.85, blue: 0.9)
            case .custom: return Color(red: 0.4, green: 0.6, blue: 0.9)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add Special Day")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.3, blue: 0.5),
                                            Color(red: 0.3, green: 0.4, blue: 0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Create a beautiful memory")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                        
                        // Name Section
                        VStack(spacing: 16) {
                            // First Name
                            VStack(alignment: .leading, spacing: 10) {
                                Label("First Name", systemImage: "person.fill")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                TextField("", text: $firstName, prompt: Text("Enter first name").foregroundColor(.secondary.opacity(0.6)))
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                                    )
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Last Name", systemImage: "person.fill")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                TextField("", text: $lastName, prompt: Text("Enter last name").foregroundColor(.secondary.opacity(0.6)))
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        
                        // Photo Section (Optional)
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Photo (Optional)", systemImage: "photo")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    HStack {
                                        if let photo = eventPhoto {
                                            Image(uiImage: photo)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        } else {
                                            HStack(spacing: 12) {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                                Text("Add Photo")
                                                    .font(.system(size: 17, weight: .regular))
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(height: 60)
                                        }
                                        
                                        Spacer()
                                        
                                        if eventPhoto != nil {
                                            Button(action: {
                                                eventPhoto = nil
                                                selectedPhoto = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                            }
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if eventPhoto == nil {
                                    Text("Add a photo to personalize this event")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 32)
                        
                        // Event Type Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Event Type")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(EventType.allCases, id: \.self) { eventType in
                                    EventTypeCard(
                                        eventType: eventType,
                                        isSelected: selectedType == eventType,
                                        showingCustomInput: showingCustomOccasionInput && eventType == .custom,
                                        customOccasionName: $customOccasionName,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                if selectedType == eventType {
                                                    selectedType = nil
                                                    showingCustomOccasionInput = false
                                                    dateSelected = false
                                                } else {
                                                    selectedType = eventType
                                                    dateSelected = false // Reset date selection when type changes
                                                    if eventType == .custom {
                                                        showingCustomOccasionInput = true
                                                    } else {
                                                        showingCustomOccasionInput = false
                                                    }
                                                }
                                            }
                                        },
                                        onAddTap: {
                                            if eventType == .custom && !showingCustomOccasionInput {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedType = eventType
                                                    showingCustomOccasionInput = true
                                                }
                                            } else {
                                                showingCalendar = true
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 40)
                        
                        // Create Button - Sadece tüm bilgiler doldurulduğunda görünür
                        if canCreateEvent {
                            VStack(spacing: 16) {
                                Button(action: {
                                    saveEvent()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text("Create")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.2, green: 0.3, blue: 0.5),
                                                Color(red: 0.3, green: 0.4, blue: 0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(
                                        color: Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.4),
                                        radius: 12,
                                        x: 0,
                                        y: 4
                                    )
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.bottom, 40)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary.opacity(0.6))
                        .background(Circle().fill(.ultraThinMaterial))
                        .padding(.top, 8)
                        .padding(.trailing, 20)
                }
            }
            .sheet(isPresented: $showingCalendar) {
                CalendarPickerView(
                    selectedDate: $selectedDate,
                    onDateSelected: {
                        showingCalendar = false
                        dateSelected = true
                        if selectedType == .custom {
                            showingIconSelector = true
                        }
                    }
                )
            }
            .sheet(isPresented: $showingIconSelector) {
                IconSelectorView(
                    selectedIcon: $selectedIcon,
                    onIconSelected: {
                        showingIconSelector = false
                    }
                )
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        eventPhoto = image
                    }
                }
            }
        }
    }
    
    // Computed property to check if event can be created
    private var canCreateEvent: Bool {
        guard let eventType = selectedType else { return false }
        guard dateSelected else { return false }
        
        // If custom event, customOccasionName must not be empty
        if eventType == .custom {
            return !customOccasionName.isEmpty
        }
        
        return true
    }
    
    private func saveEvent() {
        guard let eventType = selectedType else { return }
        
        let finalIcon = selectedIcon.isEmpty ? eventType.defaultIcon : selectedIcon
        let customName = eventType == .custom ? (customOccasionName.isEmpty ? nil : customOccasionName) : nil
        let photoData = eventPhoto?.jpegData(compressionQuality: 0.8)
        
        let newEvent = UserEvent(
            firstName: firstName,
            lastName: lastName,
            eventType: eventType.title,
            customName: customName,
            date: selectedDate,
            icon: finalIcon,
            photoData: photoData
        )
        
        userEvents.append(newEvent)
        print("✅ Event saved: \(newEvent.displayName) on \(selectedDate)")
        dismiss()
    }
}

struct EventTypeCard: View {
    let eventType: AddSpecialDayView.EventType
    let isSelected: Bool
    let showingCustomInput: Bool
    @Binding var customOccasionName: String
    let onTap: () -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.2),
                                    Color(red: 0.3, green: 0.4, blue: 0.6).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: eventType.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.3, blue: 0.5),
                                    Color(red: 0.3, green: 0.4, blue: 0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text(eventType.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if eventType == .custom && !showingCustomInput {
                        Text("Create your custom occasion")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(red: 0.2, green: 0.3, blue: 0.5) : Color(.systemGray5))
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.2), value: isSelected)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.2) : .black.opacity(0.04),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.4) : Color.clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture {
                onTap()
            }
            
            // Custom Input Field
            if showingCustomInput && eventType == .custom {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Occasion Name")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    TextField("", text: $customOccasionName, prompt: Text("Enter occasion name").foregroundColor(.secondary.opacity(0.6)))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 20)
                }
            }
            
            // Add Button
            if isSelected {
                Button(action: onAddTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Select Date")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.3, blue: 0.5),
                                Color(red: 0.3, green: 0.4, blue: 0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: showingCustomInput)
    }
}

#Preview {
    AddSpecialDayView()
}

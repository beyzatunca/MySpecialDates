//
//  AddSpecialDayView.swift
//  MySpecialDates
//
//  Created by Beyza Erdemli on 17.09.2025.
//

import SwiftUI

struct AddSpecialDayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedType: EventType? = nil
    @State private var showingCalendar = false
    @State private var showingCustomOccasionInput = false
    @State private var customOccasionName = ""
    @State private var selectedDate = Date()
    @State private var showingIconSelector = false
    @State private var selectedIcon = "🎉"
    
    enum EventType: CaseIterable {
        case birthday
        case anniversary
        case custom
        
        var title: String {
            switch self {
            case .birthday: return "Birthday"
            case .anniversary: return "Anniversary"
            case .custom: return "Your Own Occasion"
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .birthday: return "🎂"
            case .anniversary: return "💍"
            case .custom: return "🎉"
            }
        }
        
        var icon: String {
            switch self {
            case .birthday: return "birthday.cake.fill"
            case .anniversary: return "heart.fill"
            case .custom: return "sparkles"
            }
        }
        
        var color: Color {
            switch self {
            case .birthday: return Color(red: 1.0, green: 0.6, blue: 0.7)
            case .anniversary: return Color(red: 0.9, green: 0.4, blue: 0.6)
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
                                                } else {
                                                    selectedType = eventType
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
                        if selectedType == .custom {
                            showingIconSelector = true
                        } else {
                            saveEvent()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingIconSelector) {
                IconSelectorView(
                    selectedIcon: $selectedIcon,
                    onIconSelected: {
                        showingIconSelector = false
                        saveEvent()
                    }
                )
            }
        }
    }
    
    private func saveEvent() {
        // TODO: Save event to database
        print("Saving event: \(firstName) \(lastName), Type: \(selectedType?.title ?? ""), Date: \(selectedDate), Icon: \(selectedIcon)")
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
                                    eventType.color.opacity(0.2),
                                    eventType.color.opacity(0.1)
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
                                    eventType.color,
                                    eventType.color.opacity(0.7)
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
                        .fill(isSelected ? eventType.color : Color(.systemGray5))
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
                        color: isSelected ? eventType.color.opacity(0.2) : .black.opacity(0.04),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? eventType.color.opacity(0.4) : Color.clear,
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
                                eventType.color,
                                eventType.color.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: eventType.color.opacity(0.4),
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

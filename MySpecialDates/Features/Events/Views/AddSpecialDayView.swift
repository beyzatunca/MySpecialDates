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
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add Special Day")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                        
                        Text("Create a new special occasion to remember")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Name Fields
                    VStack(spacing: 16) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("Enter first name", text: $firstName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("Enter last name", text: $lastName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Event Type Selection
                    VStack(spacing: 20) {
                        ForEach(EventType.allCases, id: \.self) { eventType in
                            EventTypeRow(
                                eventType: eventType,
                                isSelected: selectedType == eventType,
                                showingCustomInput: showingCustomOccasionInput && eventType == .custom,
                                customOccasionName: $customOccasionName,
                                onTap: {
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
                                },
                                onAddTap: {
                                    if eventType == .custom && !showingCustomOccasionInput {
                                        selectedType = eventType
                                        showingCustomOccasionInput = true
                                    } else {
                                        showingCalendar = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCalendar) {
                CalendarPickerView(
                    selectedDate: $selectedDate,
                    onDateSelected: {
                        showingCalendar = false
                        if selectedType == .custom {
                            showingIconSelector = true
                        } else {
                            // Save the event directly
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

struct EventTypeRow: View {
    let eventType: AddSpecialDayView.EventType
    let isSelected: Bool
    let showingCustomInput: Bool
    @Binding var customOccasionName: String
    let onTap: () -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Row
            HStack(spacing: 16) {
                // Selection Circle
                Button(action: onTap) {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.gray.opacity(0.3), lineWidth: 2)
                        .fill(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .opacity(isSelected ? 1 : 0)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Event Type Title
                Text(eventType.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Add Button
                Button(action: onAddTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.25, green: 0.35, blue: 0.45))
                    .cornerRadius(20)
                }
                .disabled(!isSelected)
                .opacity(isSelected ? 1 : 0.5)
            }
            
            // Custom Occasion Input (only for Your Own Occasion)
            if showingCustomInput && eventType == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's the special day?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 40) // Align with the title
                    
                    TextField("Enter occasion name", text: $customOccasionName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding(.leading, 40) // Align with the title
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.05) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    AddSpecialDayView()
}

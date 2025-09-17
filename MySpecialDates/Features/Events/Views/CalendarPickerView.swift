//
//  CalendarPickerView.swift
//  MySpecialDates
//
//  Created by Beyza Erdemli on 17.09.2025.
//

import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Date")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Choose the date for this special occasion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 20)
                
                // Selected Date Display
                VStack(spacing: 8) {
                    Text("Selected Date")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Confirm Button
                    Button(action: onDateSelected) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Confirm Date")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45))
                        .cornerRadius(12)
                    }
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    CalendarPickerView(selectedDate: .constant(Date())) {
        print("Date selected")
    }
}

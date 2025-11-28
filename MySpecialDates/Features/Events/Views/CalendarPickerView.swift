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
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Select Date")
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
                        
                        Text("Choose the perfect date")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                    
                    // Calendar
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 24)
                    
                    // Selected Date Display
                    VStack(spacing: 12) {
                        Text("Selected Date")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(selectedDate, style: .date)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 32)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Confirm Button
                        Button(action: onDateSelected) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Confirm Date")
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
                            .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.3), radius: 12, x: 0, y: 4)
                        }
                        
                        // Cancel Button
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
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
        }
    }
}

#Preview {
    CalendarPickerView(selectedDate: .constant(Date())) {
        print("Date selected")
    }
}

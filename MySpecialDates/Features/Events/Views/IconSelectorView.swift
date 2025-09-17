//
//  IconSelectorView.swift
//  MySpecialDates
//
//  Created by Beyza Erdemli on 17.09.2025.
//

import SwiftUI

struct IconSelectorView: View {
    @Binding var selectedIcon: String
    let onIconSelected: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let availableIcons = [
        // Celebrations
        "🎉", "🎊", "🎈", "🎁", "🎂", "🍰", "🎀", "✨",
        // Love & Relationships
        "❤️", "💕", "💖", "💍", "💒", "👫", "👪", "💐",
        // Achievements
        "🏆", "🎖️", "🏅", "🎓", "📜", "⭐", "🌟", "💫",
        // Travel & Adventure
        "✈️", "🏖️", "🏔️", "🗺️", "🎒", "📸", "🌍", "🚗",
        // Work & Career
        "💼", "👔", "💻", "📊", "🎯", "🚀", "💡", "📈",
        // Health & Fitness
        "💪", "🏃", "🧘", "🏋️", "🥇", "🎾", "⚽", "🏀",
        // Food & Dining
        "🍕", "🍔", "🍣", "🍷", "☕", "🍪", "🥂", "🍾",
        // Nature & Animals
        "🌸", "🌺", "🌻", "🦋", "🐱", "🐶", "🌙", "☀️",
        // Activities
        "🎵", "🎸", "🎨", "📚", "🎭", "🎪", "🎳", "🎲"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Icon")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Choose an icon that represents your special occasion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Selected Icon Preview
                VStack(spacing: 12) {
                    Text("Selected Icon")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(selectedIcon)
                        .font(.system(size: 48))
                        .frame(width: 80, height: 80)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.3), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 20)
                
                // Icon Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Text(icon)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedIcon == icon 
                                        ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.2)
                                        : Color(.systemGray6)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedIcon == icon 
                                                ? Color(red: 0.25, green: 0.35, blue: 0.45)
                                                : Color.clear, 
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Confirm Button
                    Button(action: onIconSelected) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Confirm Icon")
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
    IconSelectorView(selectedIcon: .constant("🎉")) {
        print("Icon selected")
    }
}

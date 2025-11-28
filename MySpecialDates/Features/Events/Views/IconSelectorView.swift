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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Select Icon")
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
                        
                        Text("Choose an icon that represents your occasion")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Selected Icon Preview
                    VStack(spacing: 12) {
                        Text("Selected")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(selectedIcon)
                            .font(.system(size: 64))
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.15),
                                                Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.3),
                                                Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    }
                    .padding(.bottom, 32)
                    
                    // Icon Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                        selectedIcon = icon
                                    }
                                }) {
                                    Text(icon)
                                        .font(.system(size: 36))
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    selectedIcon == icon
                                                    ? LinearGradient(
                                                        colors: [
                                                            Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.2),
                                                            Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [
                                                            Color(.systemGray6),
                                                            Color(.systemGray6).opacity(0.8)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .shadow(
                                                    color: selectedIcon == icon
                                                    ? Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.2)
                                                    : .black.opacity(0.04),
                                                    radius: selectedIcon == icon ? 8 : 4,
                                                    x: 0,
                                                    y: selectedIcon == icon ? 4 : 2
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedIcon == icon
                                                    ? Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.5)
                                                    : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Confirm Button
                        Button(action: onIconSelected) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Confirm Icon")
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
    IconSelectorView(selectedIcon: .constant("🎉")) {
        print("Icon selected")
    }
}

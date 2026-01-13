import SwiftUI

struct CardTemplateGridView: View {
    let templates: [CardTemplate]
    let onTemplateSelected: (CardTemplate) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(templates) { template in
                TemplateCardView(template: template) {
                    onTemplateSelected(template)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Template Card View
struct TemplateCardView: View {
    let template: CardTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Preview Image
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.9, blue: 0.95),
                                Color(red: 0.85, green: 0.85, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            // Template Icon based on category
                            Image(systemName: iconForCategory(template.category))
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.8))
                            
                            if template.supportsUserPhoto {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Template Name
                Text(template.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForCategory(_ category: CardTemplate.CardCategory) -> String {
        switch category {
        case .birthday:
            return "birthday.cake.fill"
        case .anniversary:
            return "heart.fill"
        case .graduation:
            return "graduationcap.fill"
        case .wedding:
            return "heart.circle.fill"
        case .general:
            return "gift.fill"
        }
    }
}


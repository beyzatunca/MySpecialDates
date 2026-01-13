import SwiftUI
import UIKit
import UIKit

struct ModernTemplateGridView: View {
    let templates: [CardTemplate]
    let onTemplateSelected: (CardTemplate) -> Void
    let onQuickUse: (CardTemplate) -> Void
    let onCustomize: (CardTemplate) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(templates) { template in
                ModernTemplateCard(
                    template: template,
                    onTap: { onTemplateSelected(template) },
                    onQuickUse: { onQuickUse(template) },
                    onCustomize: { onCustomize(template) }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Modern Template Card
struct ModernTemplateCard: View {
    let template: CardTemplate
    let onTap: () -> Void
    let onQuickUse: () -> Void
    let onCustomize: () -> Void
    
    @State private var isPressed = false
    @State private var loadedImage: UIImage? = nil
    @State private var imageAspectRatio: CGFloat? = nil
    
    // MARK: - Image Loading
    private func loadImage() {
        // Use ImageAssetHelper to load image with multiple fallback methods
        loadedImage = ImageAssetHelper.loadImage(named: template.previewImageName)
        
        if let image = loadedImage {
            // Görselin gerçek aspect ratio'sunu hesapla
            let width = image.size.width
            let height = image.size.height
            if height > 0 {
                imageAspectRatio = width / height
            }
        } else {
            imageAspectRatio = nil
            print("⚠️ Image not found: \(template.previewImageName)")
            print("   📝 To fix: Add '\(template.previewImageName)' as an Image Set in Assets.xcassets")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Template Preview - Çerçevesiz, tüm kartlar aynı boyutta
            ZStack {
                // Try to load image from Assets - container'ı tamamen doldur
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    // Fallback gradient (only if image not found)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: template),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: iconForCategory(template.category))
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(template.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                        )
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .onAppear {
                loadImage()
            }
            .onChange(of: template.previewImageName) { _, _ in
                loadImage()
            }
            .overlay(
                // Quick action buttons overlay
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            Button(action: onQuickUse) {
                                Label("Quick Use", systemImage: "bolt.fill")
                            }
                            Button(action: onCustomize) {
                                Label("Customize", systemImage: "pencil")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            )
            
            // Template Info - Çerçevesiz, sadece metin - AddSpecialDayView ile aynı renkler
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(template.category.rawValue.capitalized)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
        }
        .padding(.bottom, 16)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            onTap()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private func gradientColors(for template: CardTemplate) -> [Color] {
        switch template.category {
        case .birthday:
            return [Color(red: 1.0, green: 0.6, blue: 0.7), Color(red: 0.9, green: 0.4, blue: 0.6)]
        case .anniversary:
            return [Color(red: 0.9, green: 0.4, blue: 0.6), Color(red: 0.7, green: 0.3, blue: 0.5)]
        case .graduation:
            return [Color(red: 0.3, green: 0.5, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.7)]
        case .wedding:
            return [Color(red: 0.95, green: 0.85, blue: 0.9), Color(red: 0.9, green: 0.75, blue: 0.85)]
        case .general:
            return [Color(red: 0.4, green: 0.6, blue: 0.9), Color(red: 0.3, green: 0.5, blue: 0.8)]
        }
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


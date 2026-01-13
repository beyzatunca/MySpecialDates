import SwiftUI
import UIKit

struct FinalCardPreviewView: View {
    let template: CardTemplate
    let message: String
    let userPhoto: UIImage?
    let photoPosition: CGPoint?
    let photoScale: CGFloat?
    let photoRotation: Double?
    
    @State private var backgroundImage: UIImage? = nil
    
    init(template: CardTemplate, message: String, userPhoto: UIImage?, photoPosition: CGPoint? = nil, photoScale: CGFloat? = nil, photoRotation: Double? = nil) {
        self.template = template
        self.message = message
        self.userPhoto = userPhoto
        self.photoPosition = photoPosition
        self.photoScale = photoScale
        self.photoRotation = photoRotation
    }
    
    var body: some View {
        ZStack {
            // Background Image or Gradient
            ZStack {
                // Fallback gradient (always shown as background)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: backgroundColors(for: template),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 400, height: 600)
                
                // Template background image (if loaded)
                if let bgImage = backgroundImage {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 400, height: 600)
                        .clipped()
                        .cornerRadius(24)
                }
            }
            
            ZStack {
                // User Photo (if available) - positioned according to editor settings
                if let photo = userPhoto {
                    let scale = photoScale ?? 1.0
                    let rotation = photoRotation ?? 0.0
                    let position = photoPosition ?? CGPoint(x: 200, y: 300)
                    
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150 * scale, height: 150 * scale)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        .position(position)
                        .rotationEffect(.degrees(rotation))
                }
                
                // Message and Icon (only if photo is not positioned)
                // Eğer mesaj boşsa, sadece icon göster veya hiçbir şey gösterme
                if !message.isEmpty {
                    if photoPosition == nil {
                        VStack(spacing: 20) {
                            // Message
                            Text(message)
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            
                            // Template Icon
                            Image(systemName: iconForCategory(template.category))
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        // Message only (photo is positioned)
                        Text(message)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .position(x: 200, y: 500)
                    }
                } else {
                    // Mesaj yoksa ve fotoğraf da yoksa, sadece icon göster
                    if photoPosition == nil && userPhoto == nil {
                        Image(systemName: iconForCategory(template.category))
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    // Eğer fotoğraf varsa, hiçbir şey gösterme (sadece fotoğraf gösterilir)
                }
            }
        }
        .frame(width: 400, height: 600)
        .onAppear {
            loadBackgroundImage()
        }
    }
    
    // MARK: - Image Loading
    private func loadBackgroundImage() {
        // Use ImageAssetHelper to load template background image
        backgroundImage = ImageAssetHelper.loadImage(named: template.backgroundImageName)
        
        if backgroundImage == nil {
            print("⚠️ Background image not found: \(template.backgroundImageName)")
        } else {
            print("✅ Background image loaded: \(template.backgroundImageName)")
        }
    }
    
    private func backgroundColors(for template: CardTemplate) -> [Color] {
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


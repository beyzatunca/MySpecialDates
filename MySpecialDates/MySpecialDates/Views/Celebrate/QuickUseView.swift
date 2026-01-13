import SwiftUI
import UIKit

struct QuickUseView: View {
    let template: CardTemplate
    @ObservedObject var viewModel: CelebrateViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingShareSheet = false
    @State private var cardImage: UIImage?
    @State private var isRendering = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Uygulamanın renk paletine uygun
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.35),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Card Preview - Sadece template görseli, metin yok
                        QuickUseTemplateView(template: template)
                        .padding(.top, 20)
                        
                        // Share Options
                        VStack(spacing: 16) {
                            Text("Share via")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                // WhatsApp
                                ShareButton(
                                    icon: "message.fill",
                                    label: "WhatsApp",
                                    color: Color(red: 0.18, green: 0.75, blue: 0.45)
                                ) {
                                    shareViaWhatsApp()
                                }
                                
                                // Email
                                ShareButton(
                                    icon: "envelope.fill",
                                    label: "Email",
                                    color: Color(red: 0.3, green: 0.5, blue: 0.8)
                                ) {
                                    shareViaEmail()
                                }
                                
                                // SMS
                                ShareButton(
                                    icon: "message.fill",
                                    label: "SMS",
                                    color: Color(red: 0.9, green: 0.4, blue: 0.6)
                                ) {
                                    shareViaSMS()
                                }
                            }
                            
                            // More Options
                            Button(action: {
                                renderAndShare()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("More Options")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = cardImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
    }
    
    private func shareViaWhatsApp() {
        renderCard { image in
            if let image = image,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                // WhatsApp URL scheme
                if let whatsappURL = URL(string: "whatsapp://send?text=") {
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        // Save image temporarily and share
                        renderAndShare()
                    } else {
                        // Fallback to general share
                        renderAndShare()
                    }
                }
            }
        }
    }
    
    private func shareViaEmail() {
        renderCard { image in
            if let image = image {
                if let emailURL = URL(string: "mailto:") {
                    if UIApplication.shared.canOpenURL(emailURL) {
                        renderAndShare()
                    }
                }
            }
        }
    }
    
    private func shareViaSMS() {
        renderCard { image in
            if let image = image {
                if let smsURL = URL(string: "sms:") {
                    if UIApplication.shared.canOpenURL(smsURL) {
                        renderAndShare()
                    }
                }
            }
        }
    }
    
    private func renderAndShare() {
        isRendering = true
        renderCard { image in
            isRendering = false
            if let image = image {
                cardImage = image
                showingShareSheet = true
            }
        }
    }
    
    private func renderCard(completion: @escaping (UIImage?) -> Void) {
        let previewView = QuickUseTemplateView(template: template)
        
        let renderer = ImageRenderer(content: previewView)
        renderer.scale = 2.0
        
        completion(renderer.uiImage)
    }
}

// MARK: - Quick Use Template View (Sadece görsel, metin yok)
struct QuickUseTemplateView: View {
    let template: CardTemplate
    @State private var backgroundImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // Fallback gradient
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
        .frame(width: 400, height: 600)
        .onAppear {
            loadBackgroundImage()
        }
    }
    
    private func loadBackgroundImage() {
        backgroundImage = ImageAssetHelper.loadImage(named: template.backgroundImageName)
        
        if backgroundImage == nil {
            print("⚠️ Background image not found: \(template.backgroundImageName)")
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
}

// MARK: - Share Button
struct ShareButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}


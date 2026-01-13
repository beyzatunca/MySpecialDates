import SwiftUI

struct CardEditorView: View {
    @ObservedObject var viewModel: CelebrateViewModel
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var cardImage: UIImage?
    @State private var showingShareSheet = false
    @State private var isRendering = false
    @State private var flipAngle: Double = 0
    @State private var showBack = false
    @State private var isFlipped = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let template = viewModel.selectedTemplate {
                            // Card Preview with 3D Flip Animation (Kartpostal gibi)
                            ZStack {
                                // Back of card (with message)
                                CardBackView(
                                    template: template,
                                    message: viewModel.customMessage,
                                    userPhoto: viewModel.userPhoto,
                                    photoPosition: viewModel.userPhoto != nil ? viewModel.photoPosition : nil,
                                    photoScale: viewModel.userPhoto != nil ? viewModel.photoScale : nil,
                                    photoRotation: viewModel.userPhoto != nil ? viewModel.photoRotation : nil
                                )
                                .rotation3DEffect(
                                    .degrees(flipAngle),
                                    axis: (x: 0, y: 1, z: 0),
                                    perspective: 0.5
                                )
                                .opacity(flipAngle > 90 ? 1 : 0)
                                
                                // Front of card (template image)
                                CardFrontView(template: template)
                                    .rotation3DEffect(
                                        .degrees(flipAngle),
                                        axis: (x: 0, y: 1, z: 0),
                                        perspective: 0.5
                                    )
                                    .opacity(flipAngle > 90 ? 0 : 1)
                            }
                            .frame(width: 400, height: 600)
                            .padding(.top, 20)
                            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
                            .onTapGesture {
                                // Flip card on tap
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    isFlipped.toggle()
                                    flipAngle = isFlipped ? 180 : 0
                                    showBack = isFlipped
                                }
                            }
                            .onAppear {
                                // Start animation: show front first, then flip to back
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation(.easeInOut(duration: 1.5)) {
                                        flipAngle = 180
                                        showBack = true
                                        isFlipped = true
                                    }
                                }
                            }
                            
                            // Action Buttons - Apple Design Guidelines
                            VStack(spacing: 16) {
                                // Share Button - Primary Action (Apple Blue)
                                Button(action: {
                                    renderCard()
                                }) {
                                    HStack {
                                        if isRendering {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                        Text("Share Card")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        Capsule()
                                            .fill(Color.accentColor)
                                    )
                                }
                                .disabled(isRendering)
                                
                                // Save Button - Secondary Action
                                Button(action: {
                                    let card = viewModel.createCard()
                                    if card != nil {
                                        onSave()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save Card")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        } else {
                            Text("No template selected")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 100)
                        }
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
    
    private func renderCard() {
        isRendering = true
        
        guard let template = viewModel.selectedTemplate else {
            isRendering = false
            return
        }
        
        let previewView = FinalCardPreviewView(
            template: template,
            message: viewModel.customMessage,
            userPhoto: viewModel.userPhoto,
            photoPosition: viewModel.userPhoto != nil ? viewModel.photoPosition : nil,
            photoScale: viewModel.userPhoto != nil ? viewModel.photoScale : nil,
            photoRotation: viewModel.userPhoto != nil ? viewModel.photoRotation : nil
        )
        
        let renderer = ImageRenderer(content: previewView)
        renderer.scale = 2.0 // High resolution
        
        if let uiImage = renderer.uiImage {
            cardImage = uiImage
            showingShareSheet = true
        }
        
        isRendering = false
    }
}

// MARK: - Card Front View (Template Image)
struct CardFrontView: View {
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
            
            // Template background image
            if let bgImage = backgroundImage {
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 400, height: 600)
                    .clipped()
                    .cornerRadius(24)
            }
        }
        .onAppear {
            loadBackgroundImage()
        }
    }
    
    private func loadBackgroundImage() {
        backgroundImage = ImageAssetHelper.loadImage(named: template.backgroundImageName)
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

// MARK: - Card Back View (Message and Photo)
struct CardBackView: View {
    let template: CardTemplate
    let message: String
    let userPhoto: UIImage?
    let photoPosition: CGPoint?
    let photoScale: CGFloat?
    let photoRotation: Double?
    @State private var backgroundImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // Background - Simple gradient for back
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.95, blue: 0.98),
                            Color(red: 0.9, green: 0.9, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 400, height: 600)
            
            // Message and Photo on back - Metin düz okunacak şekilde ters döndürülmüş
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
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .position(position)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(x: -1, y: 1) // Mirror to fix orientation
                }
                
                // Message on back - Metin düz okunacak şekilde
                // Eğer mesaj boşsa, sadece icon göster
                if !message.isEmpty {
                    if photoPosition == nil {
                        VStack(spacing: 20) {
                            Text(message)
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
                                .scaleEffect(x: -1, y: 1) // Mirror to fix orientation
                            
                            Image(systemName: iconForCategory(template.category))
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.6))
                                .scaleEffect(x: -1, y: 1) // Mirror to fix orientation
                        }
                    } else {
                        // Message only (photo is positioned)
                        Text(message)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
                            .position(x: 200, y: 500)
                            .scaleEffect(x: -1, y: 1) // Mirror to fix orientation
                    }
                } else {
                    // Mesaj yoksa sadece icon göster
                    Image(systemName: iconForCategory(template.category))
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                        .scaleEffect(x: -1, y: 1) // Mirror to fix orientation
                }
            }
        }
        .onAppear {
            loadBackgroundImage()
        }
    }
    
    private func loadBackgroundImage() {
        backgroundImage = ImageAssetHelper.loadImage(named: template.backgroundImageName)
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

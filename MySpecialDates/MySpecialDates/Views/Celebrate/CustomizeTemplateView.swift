import SwiftUI
import PhotosUI

struct CustomizeTemplateView: View {
    let template: CardTemplate
    @ObservedObject var viewModel: CelebrateViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingEditor = false
    @State private var showingAIPrompt = false
    @State private var showingPhotoEditor = false
    @FocusState private var isMessageFocused: Bool
    
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
                        // Header
                        VStack(spacing: 8) {
                            Text(template.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Customize your card")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Message Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Message")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // AI Generate Button - Apple Design Guidelines
                                Button(action: {
                                    Task {
                                        await viewModel.generateAIMessage(
                                            for: template,
                                            recipientName: nil
                                        )
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        if viewModel.isGeneratingMessage {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "sparkles")
                                        }
                                        Text("AI Generate")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.accentColor)
                                    )
                                }
                                .disabled(viewModel.isGeneratingMessage)
                                
                                // AI Prompt Button
                                Button(action: {
                                    showingAIPrompt = true
                                }) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(Color.accentColor.opacity(0.3))
                                        )
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if viewModel.customMessage.isEmpty {
                                    Text("Write your message or use AI to generate one")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                }
                                
                                TextEditor(text: $viewModel.customMessage)
                                    .frame(height: 150)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .focused($isMessageFocused)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isMessageFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .onAppear {
                                // Set text color to black for TextEditor
                                UITextView.appearance().textColor = .black
                            }
                            
                            // Photo Selection (if supported) - Message alanının altında
                            if template.supportsUserPhoto {
                                VStack(spacing: 12) {
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        HStack {
                                            if let photo = viewModel.userPhoto {
                                                Image(uiImage: photo)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            } else {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "photo.badge.plus")
                                                        .font(.system(size: 18))
                                                        .foregroundColor(.white.opacity(0.8))
                                                    Text("Add Photo")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                                .frame(height: 60)
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial)
                                        )
                                    }
                                    .onChange(of: selectedPhoto) { old, new in
                                        Task {
                                            if let data = try? await new?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                viewModel.setUserPhoto(image)
                                                showingPhotoEditor = true
                                            }
                                        }
                                    }
                                    
                                    // Photo Action Buttons (if photo exists)
                                    if viewModel.userPhoto != nil {
                                        HStack(spacing: 12) {
                                            // Edit Photo Button
                                            Button(action: {
                                                showingPhotoEditor = true
                                            }) {
                                                HStack {
                                                    Image(systemName: "slider.horizontal.3")
                                                        .font(.system(size: 16))
                                                    Text("Position & Edit")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundColor(.white.opacity(0.9))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.accentColor.opacity(0.3))
                                                )
                                            }
                                            
                                            // Remove Photo Button
                                            Button(action: {
                                                viewModel.setUserPhoto(nil)
                                            }) {
                                                HStack {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 16))
                                                    Text("Remove")
                                                        .font(.system(size: 14, weight: .medium))
                                                }
                                                .foregroundColor(.red.opacity(0.9))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.red.opacity(0.2))
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal, 24)
                        
                        // Continue Button - Apple Design Guidelines
                        // Kullanıcı metin eklemeden de devam edebilir
                        Button(action: {
                            showingEditor = true
                        }) {
                            Text("Continue to Preview")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor)
                                )
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
            .sheet(isPresented: $showingEditor) {
                CardEditorView(
                    viewModel: viewModel,
                    onSave: {
                        showingEditor = false
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $showingAIPrompt) {
                AIPromptView(
                    viewModel: viewModel,
                    template: template
                )
            }
            .sheet(isPresented: $showingPhotoEditor) {
                if let photo = viewModel.userPhoto {
                    PhotoEditorView(
                        template: template,
                        userPhoto: photo,
                        initialPosition: viewModel.photoPosition,
                        initialScale: viewModel.photoScale,
                        initialRotation: viewModel.photoRotation,
                        onPhotoUpdated: { position, scale, rotation in
                            viewModel.updatePhotoPosition(position, scale: scale, rotation: rotation)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - AI Prompt View
struct AIPromptView: View {
    @ObservedObject var viewModel: CelebrateViewModel
    let template: CardTemplate
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isPromptFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.35),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Customization")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Describe how you want to customize this card. AI will update the message accordingly.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Prompt")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .topLeading) {
                            if viewModel.aiPrompt.isEmpty {
                                Text("Example: 'Make it funnier' or 'Add a romantic touch'")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                            }
                            
                            TextEditor(text: $viewModel.aiPrompt)
                                .frame(height: 200)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .focused($isPromptFocused)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isPromptFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .onAppear {
                            // Set text color to black for TextEditor
                            UITextView.appearance().textColor = .black
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        Task {
                            await viewModel.updateTemplateWithPrompt(viewModel.aiPrompt)
                            dismiss()
                        }
                    }) {
                        HStack {
                            if viewModel.isGeneratingWithPrompt {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text("Apply AI Changes")
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
                    .disabled(viewModel.isGeneratingWithPrompt || viewModel.aiPrompt.isEmpty)
                    .padding(.horizontal, 24)
                    
                    Spacer()
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
        }
    }
}

// MARK: - Photo Editor View
struct PhotoEditorView: View {
    let template: CardTemplate
    let userPhoto: UIImage
    let initialPosition: CGPoint
    let initialScale: CGFloat
    let initialRotation: Double
    let onPhotoUpdated: (CGPoint, CGFloat, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var photoPosition: CGPoint
    @State private var photoScale: CGFloat
    @State private var photoRotation: Double
    @State private var backgroundImage: UIImage? = nil
    
    init(template: CardTemplate, userPhoto: UIImage, initialPosition: CGPoint, initialScale: CGFloat, initialRotation: Double, onPhotoUpdated: @escaping (CGPoint, CGFloat, Double) -> Void) {
        self.template = template
        self.userPhoto = userPhoto
        self.initialPosition = initialPosition
        self.initialScale = initialScale
        self.initialRotation = initialRotation
        self.onPhotoUpdated = onPhotoUpdated
        _photoPosition = State(initialValue: initialPosition)
        _photoScale = State(initialValue: initialScale)
        _photoRotation = State(initialValue: initialRotation)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.35),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Instructions
                    VStack(spacing: 8) {
                        Text("Position Your Photo")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Drag to move, pinch to resize, rotate with two fingers")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Template with Photo Overlay
                    GeometryReader { geometry in
                        ZStack {
                            // Template Background
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
                                    .frame(width: min(geometry.size.width - 40, 400), height: min(geometry.size.height * 0.6, 600))
                                
                                // Template background image
                                if let bgImage = backgroundImage {
                                    Image(uiImage: bgImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: min(geometry.size.width - 40, 400), height: min(geometry.size.height * 0.6, 600))
                                        .clipped()
                                        .cornerRadius(24)
                                }
                            }
                            
                            // User Photo - Draggable and Scalable
                            Image(uiImage: userPhoto)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150 * photoScale, height: 150 * photoScale)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                                .position(photoPosition)
                                .rotationEffect(.degrees(photoRotation))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            photoPosition = value.location
                                        }
                                )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, 20)
                    
                    // Controls
                    VStack(spacing: 16) {
                        // Scale Slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Size")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Slider(value: $photoScale, in: 0.5...3.0)
                                .tint(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        // Rotation Slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rotation")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Slider(value: $photoRotation, in: -180...180)
                                .tint(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        // Reset Button
                        Button(action: {
                            photoPosition = initialPosition
                            photoScale = initialScale
                            photoRotation = initialRotation
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding(.bottom, 20)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onPhotoUpdated(photoPosition, photoScale, photoRotation)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadBackgroundImage()
            }
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


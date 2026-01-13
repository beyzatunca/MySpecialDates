import SwiftUI
import PhotosUI

struct PastCardsListView: View {
    @ObservedObject var viewModel: CelebrateViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCard: CreatedCard?
    @State private var showingShareSheet = false
    @State private var showingCardDetail = false
    @State private var cardImage: UIImage?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.pastCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Cards Yet")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Create your first celebration card!")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(viewModel.pastCards) { card in
                                PastCardThumbnailView(card: card) {
                                    selectedCard = card
                                    showingCardDetail = true
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Past Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCardDetail) {
                if let card = selectedCard {
                    PastCardDetailView(card: card, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = cardImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
    }
    
    private func renderCard(_ card: CreatedCard) {
        // Find template for this card
        guard let template = viewModel.templates.first(where: { $0.id == card.templateId }) else {
            return
        }
        
        let previewView = FinalCardPreviewView(
            template: template,
            message: card.message,
            userPhoto: card.userPhoto
        )
        
        let renderer = ImageRenderer(content: previewView)
        renderer.scale = 2.0
        
        if let uiImage = renderer.uiImage {
            cardImage = uiImage
            showingShareSheet = true
        }
    }
}

// MARK: - Past Card Thumbnail View
struct PastCardThumbnailView: View {
    let card: CreatedCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 150)
                    .overlay(
                        VStack(spacing: 4) {
                            if let photo = card.userPhoto {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                            
                            Text(card.message)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                    )
                
                // Card Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.templateName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(card.createdAt, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Past Card Detail View
struct PastCardDetailView: View {
    let card: CreatedCard
    @ObservedObject var viewModel: CelebrateViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var flipAngle: Double = 0
    @State private var showBack = false
    @State private var isFlipped = false
    @State private var cardImage: UIImage?
    @State private var showingShareSheet = false
    @State private var showingEditView = false
    @State private var showingDeleteConfirmation = false
    
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
                        if let template = viewModel.templates.first(where: { $0.id == card.templateId }) {
                            // Card Preview with 3D Flip Animation (Kartpostal gibi)
                            ZStack {
                                // Back of card (with message)
                                CardBackView(
                                    template: template,
                                    message: card.message,
                                    userPhoto: card.userPhoto,
                                    photoPosition: nil, // Past cards don't have position data yet
                                    photoScale: nil,
                                    photoRotation: nil
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
                                // Edit Button - Primary Action (Apple Blue)
                                Button(action: {
                                    // Load card data into viewModel for editing
                                    viewModel.selectedTemplate = template
                                    viewModel.customMessage = card.message
                                    viewModel.setUserPhoto(card.userPhoto)
                                    showingEditView = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Card")
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
                                
                                // Share Button - Secondary Action
                                Button(action: {
                                    renderCard(card, template: template)
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Card")
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
                                
                                // Delete Button - Destructive Action
                                Button(action: {
                                    showingDeleteConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete Card")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.red)
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
                            Text("Template not found")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 100)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingEditView) {
                if let template = viewModel.selectedTemplate {
                    EditPastCardView(
                        card: card,
                        template: template,
                        viewModel: viewModel,
                        onSave: {
                            showingEditView = false
                            dismiss()
                        }
                    )
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = cardImage {
                    ShareSheet(activityItems: [image])
                }
            }
            .alert("Delete Card", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteCard(card)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this card? This action cannot be undone.")
            }
        }
    }
    
    private func renderCard(_ card: CreatedCard, template: CardTemplate) {
        let previewView = FinalCardPreviewView(
            template: template,
            message: card.message,
            userPhoto: card.userPhoto,
            photoPosition: nil,
            photoScale: nil,
            photoRotation: nil
        )
        
        let renderer = ImageRenderer(content: previewView)
        renderer.scale = 2.0
        
        if let uiImage = renderer.uiImage {
            cardImage = uiImage
            showingShareSheet = true
        }
    }
}

// MARK: - Edit Past Card View
struct EditPastCardView: View {
    let card: CreatedCard
    let template: CardTemplate
    @ObservedObject var viewModel: CelebrateViewModel
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    @State private var showingAIPrompt = false
    @State private var showingPhotoEditor = false
    @State private var selectedPhoto: PhotosPickerItem?
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
                            Text("Edit Card")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Update your card")
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
                                UITextView.appearance().textColor = .black
                            }
                            
                            // Photo Selection (if supported)
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
                        
                        // Save Button - Apple Design Guidelines
                        Button(action: {
                            updateCard()
                            showingEditor = true
                        }) {
                            Text("Save Changes")
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
                        onSave()
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
            .onAppear {
                // Load card data
                viewModel.customMessage = card.message
                viewModel.setUserPhoto(card.userPhoto)
            }
        }
    }
    
    private func updateCard() {
        // Update the card in the pastCards array
        if let index = viewModel.pastCards.firstIndex(where: { $0.id == card.id }) {
            let updatedCard = CreatedCard(
                id: card.id,
                templateId: card.templateId,
                message: viewModel.customMessage.isEmpty ? "Happy \(template.category.rawValue.capitalized)!" : viewModel.customMessage,
                userPhotoData: viewModel.userPhoto?.jpegData(compressionQuality: 0.8),
                createdAt: card.createdAt,
                templateName: card.templateName
            )
            viewModel.pastCards[index] = updatedCard
            viewModel.savePastCards()
        }
    }
}

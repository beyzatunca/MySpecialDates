import SwiftUI
import PhotosUI

struct EditCustomTemplateView: View {
    let template: CardTemplate
    @ObservedObject var viewModel: CelebrateViewModel
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName: String = ""
    @State private var templateDescription: String = ""
    @State private var selectedCategory: CardTemplate.CardCategory = .general
    @State private var selectedTone: CardTemplate.MessageTone = .sweet
    @State private var supportsPhoto: Bool = false
    @State private var backgroundImage: UIImage?
    @State private var selectedBackground: PhotosPickerItem?
    @State private var customMessage: String = ""
    @State private var backgroundColor: Color = Color.white
    @State private var useSolidColor: Bool = false
    @State private var examplePhoto: UIImage?
    @State private var selectedExamplePhoto: PhotosPickerItem?
    @FocusState private var isMessageFocused: Bool
    
    init(template: CardTemplate, viewModel: CelebrateViewModel, onSave: @escaping () -> Void) {
        self.template = template
        self.viewModel = viewModel
        self.onSave = onSave
        
        _templateName = State(initialValue: template.name)
        _templateDescription = State(initialValue: template.description)
        _selectedCategory = State(initialValue: template.category)
        _selectedTone = State(initialValue: template.defaultTone)
        _supportsPhoto = State(initialValue: template.supportsUserPhoto)
    }
    
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Edit Template")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Modify your custom template")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        // Template Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Template Name")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter template name", text: $templateName)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(CardTemplate.CardCategory.allCases, id: \.self) { category in
                                        CategoryChip(
                                            title: category.rawValue.capitalized,
                                            icon: iconForCategory(category),
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Tone Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Message Tone")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(CardTemplate.MessageTone.allCases, id: \.self) { tone in
                                        ToneChip(
                                            title: tone.rawValue.capitalized,
                                            isSelected: selectedTone == tone
                                        ) {
                                            selectedTone = tone
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Background Image or Color
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Background")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if backgroundImage != nil {
                                    Button(action: {
                                        backgroundImage = nil
                                        selectedBackground = nil
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "trash")
                                            Text("Remove")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red.opacity(0.9))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.red.opacity(0.2))
                                        )
                                    }
                                }
                            }
                            
                            Toggle(isOn: $useSolidColor) {
                                Text(useSolidColor ? "Use Solid Color" : "Use Image")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .tint(.accentColor)
                            
                            if useSolidColor {
                                ColorPicker("Background Color", selection: $backgroundColor)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(backgroundColor)
                                    .frame(height: 200)
                            } else {
                                PhotosPicker(selection: $selectedBackground, matching: .images) {
                                    if let image = backgroundImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    } else {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 200)
                                            .overlay(
                                                VStack(spacing: 12) {
                                                    Image(systemName: "photo.badge.plus")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.white.opacity(0.7))
                                                    Text("Add background image")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                            )
                                    }
                                }
                                .onChange(of: selectedBackground) { old, new in
                                    Task {
                                        if let data = try? await new?.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            backgroundImage = image
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Options
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $supportsPhoto) {
                                Text("Support User Photos")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .tint(.blue)
                            
                            if supportsPhoto {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Example Photo (Optional)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                        
                                        if examplePhoto != nil {
                                            Button(action: {
                                                examplePhoto = nil
                                                selectedExamplePhoto = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.red.opacity(0.9))
                                            }
                                        }
                                    }
                                    
                                    PhotosPicker(selection: $selectedExamplePhoto, matching: .images) {
                                        if let photo = examplePhoto {
                                            Image(uiImage: photo)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        } else {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(height: 150)
                                                .overlay(
                                                    VStack(spacing: 8) {
                                                        Image(systemName: "photo.badge.plus")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(.white.opacity(0.7))
                                                        Text("Add example photo")
                                                            .font(.system(size: 12, weight: .medium))
                                                            .foregroundColor(.white.opacity(0.7))
                                                    }
                                                )
                                        }
                                    }
                                    .onChange(of: selectedExamplePhoto) { old, new in
                                        Task {
                                            if let data = try? await new?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                examplePhoto = image
                                            }
                                        }
                                    }
                                    
                                    Text("This photo will be used as a preview example. Users can replace it with their own photos when using this template.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // Message
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Message")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ZStack(alignment: .topLeading) {
                                if customMessage.isEmpty {
                                    Text("Enter default message")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                }
                                
                                TextEditor(text: $customMessage)
                                    .frame(height: 120)
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
                                    .stroke(isMessageFocused ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .onAppear {
                                UITextView.appearance().textColor = .black
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Save Button
                        Button(action: {
                            updateTemplate()
                            onSave()
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
                        .disabled(templateName.isEmpty)
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
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private func updateTemplate() {
        let updatedTemplate = CardTemplate(
            id: template.id,
            name: templateName,
            previewImageName: template.previewImageName,
            backgroundImageName: template.backgroundImageName,
            supportsUserPhoto: supportsPhoto,
            defaultTone: selectedTone,
            category: selectedCategory,
            description: templateDescription.isEmpty ? "A custom \(selectedCategory.rawValue) card." : templateDescription,
            tags: [selectedCategory.rawValue, selectedTone.rawValue]
        )
        
        viewModel.updateCustomTemplate(updatedTemplate)
    }
    
    private func iconForCategory(_ category: CardTemplate.CardCategory) -> String {
        switch category {
        case .birthday: return "birthday.cake.fill"
        case .anniversary: return "heart.fill"
        case .graduation: return "graduationcap.fill"
        case .wedding: return "heart.circle.fill"
        case .general: return "gift.fill"
        }
    }
}


import SwiftUI

struct CustomTemplatesListView: View {
    @ObservedObject var viewModel: CelebrateViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: CardTemplate?
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    @State private var templateToDelete: CardTemplate?
    
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
                
                if viewModel.customTemplates.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No Custom Templates")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Create your first custom template using the + button")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("My Templates")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(viewModel.customTemplates.count) custom template\(viewModel.customTemplates.count == 1 ? "" : "s")")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            // Custom Templates Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 24) {
                                ForEach(viewModel.customTemplates) { template in
                                    CustomTemplateCard(
                                        template: template,
                                        onEdit: {
                                            selectedTemplate = template
                                            showingEdit = true
                                        },
                                        onDelete: {
                                            templateToDelete = template
                                            showingDeleteConfirmation = true
                                        },
                                        onUse: { selectedTemplate in
                                            viewModel.selectTemplate(selectedTemplate)
                                            dismiss()
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
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
                    .foregroundColor(.accentColor)
                }
            }
            .sheet(isPresented: $showingEdit) {
                if let template = selectedTemplate {
                    EditCustomTemplateView(
                        template: template,
                        viewModel: viewModel,
                        onSave: {
                            showingEdit = false
                        }
                    )
                }
            }
            .alert("Delete Template", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        viewModel.deleteCustomTemplate(template)
                        templateToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(templateToDelete?.name ?? "")'? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Custom Template Card
struct CustomTemplateCard: View {
    let template: CardTemplate
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onUse: (CardTemplate) -> Void
    @State private var loadedImage: UIImage? = nil
    
    // MARK: - Image Loading
    private func loadImage() {
        loadedImage = ImageAssetHelper.loadImage(named: template.previewImageName)
        if loadedImage == nil {
            print("⚠️ Image not found: \(template.previewImageName)")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Template Preview - Çerçevesiz, tüm kartlar aynı boyutta (ModernTemplateCard ile aynı)
            ZStack {
                // Try to load image from Assets
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
            .overlay(
                // Quick action buttons overlay - ModernTemplateCard ile aynı stil
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            Button(action: {
                                onUse(template)
                            }) {
                                Label("Use Template", systemImage: "checkmark.circle")
                            }
                            Button(action: onEdit) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(.systemGray5))
                                )
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            )
            
            // Template Info - ModernTemplateCard ile aynı stil - AddSpecialDayView ile aynı renkler
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
        .onAppear {
            loadImage()
        }
        .onChange(of: template.previewImageName) { _, _ in
            loadImage()
        }
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



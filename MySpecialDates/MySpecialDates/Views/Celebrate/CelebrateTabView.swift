import SwiftUI

struct CelebrateTabView: View {
    @StateObject private var viewModel = CelebrateViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: CardTemplate?
    @State private var showingQuickUse = false
    @State private var showingCustomize = false
    @State private var showingCreateNew = false
    @State private var showingPastCards = false
    @State private var showingEditCustomTemplate = false
    @State private var selectedCustomTemplate: CardTemplate?
    @State private var showingDeleteConfirmation = false
    @State private var templateToDelete: CardTemplate?
    @State private var searchText: String = ""
    @State private var selectedCategory: CardTemplate.CardCategory? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient - AddSpecialDayView ile aynı
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Modern Header with glassmorphism
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Celebrate")
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
                                    
                                    Text("Create & share beautiful cards")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                        
                        // Search Bar
                        VStack(spacing: 12) {
                            // Search Field
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 12)
                                
                                TextField("Search templates...", text: $searchText)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 16))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 12)
                                }
                            }
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal, 24)
                            
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // All Categories Button
                                    Button(action: {
                                        selectedCategory = nil
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "square.grid.2x2")
                                            Text("All")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedCategory == nil ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == nil ? Color.accentColor : Color(.systemGray5))
                                        )
                                    }
                                    
                                    // Category Buttons
                                    ForEach(CardTemplate.CardCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            selectedCategory = selectedCategory == category ? nil : category
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: iconForCategory(category))
                                                Text(category.rawValue.capitalized)
                                            }
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? .white : .primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == category ? Color.accentColor : Color(.systemGray5))
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        // My Templates Section
                        if !viewModel.customTemplates.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("My Templates")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Create New Template Button
                                    Button(action: {
                                        showingCreateNew = true
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(Color(.systemGray5))
                                            )
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 32)
                                
                                // Custom Templates Grid
                                let filteredCustomTemplates = filteredTemplates(viewModel.customTemplates)
                                
                                if filteredCustomTemplates.isEmpty && (!searchText.isEmpty || selectedCategory != nil) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary.opacity(0.5))
                                        Text("No templates found")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ], spacing: 24) {
                                        ForEach(filteredCustomTemplates) { template in
                                        CustomTemplateCard(
                                            template: template,
                                            onEdit: {
                                                selectedCustomTemplate = template
                                                showingEditCustomTemplate = true
                                            },
                                            onDelete: {
                                                templateToDelete = template
                                                showingDeleteConfirmation = true
                                            },
                                            onUse: { selectedTemplate in
                                                self.selectedTemplate = selectedTemplate
                                                viewModel.selectTemplate(selectedTemplate)
                                                showingCustomize = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        // Templates Grid with modern design
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Templates")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    // Create New Template Button (if no custom templates)
                                    if viewModel.customTemplates.isEmpty {
                                        Button(action: {
                                            showingCreateNew = true
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(Color(.systemGray5))
                                                )
                                        }
                                    }
                                    
                                    // History Button
                                    Button(action: {
                                        showingPastCards = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "clock.arrow.circlepath")
                                            Text("History")
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(.systemGray5))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, viewModel.customTemplates.isEmpty ? 32 : 24)
                            
                            if viewModel.templates.isEmpty {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    Text("Loading templates...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                let filteredTemplates = filteredTemplates(viewModel.templates)
                                
                                if filteredTemplates.isEmpty && (!searchText.isEmpty || selectedCategory != nil) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary.opacity(0.5))
                                        Text("No templates found")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    ModernTemplateGridView(
                                        templates: filteredTemplates,
                                    onTemplateSelected: { template in
                                        selectedTemplate = template
                                        viewModel.selectTemplate(template)
                                    },
                                    onQuickUse: { template in
                                        selectedTemplate = template
                                        viewModel.selectTemplate(template)
                                        showingQuickUse = true
                                    },
                                    onCustomize: { template in
                                        selectedTemplate = template
                                        viewModel.selectTemplate(template)
                                        showingCustomize = true
                                    }
                                    )
                                }
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.horizontal, 24)
                                    .padding(.top, 16)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                // Close Button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                        .background(Circle().fill(Color(.systemGray5)))
                }
                .padding(.top, 8)
                .padding(.trailing, 20)
            }
            .sheet(isPresented: $showingQuickUse) {
                if let template = selectedTemplate {
                    QuickUseView(
                        template: template,
                        viewModel: viewModel
                    )
                }
            }
            .sheet(isPresented: $showingCustomize) {
                if let template = selectedTemplate {
                    CustomizeTemplateView(
                        template: template,
                        viewModel: viewModel
                    )
                }
            }
            .sheet(isPresented: $showingCreateNew) {
                CreateNewTemplateView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingPastCards) {
                PastCardsListView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditCustomTemplate) {
                if let template = selectedCustomTemplate {
                    EditCustomTemplateView(
                        template: template,
                        viewModel: viewModel,
                        onSave: {
                            showingEditCustomTemplate = false
                            selectedCustomTemplate = nil
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
    
    // MARK: - Filtering Logic
    private func filteredTemplates(_ templates: [CardTemplate]) -> [CardTemplate] {
        var filtered = templates
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Search filter - Kısmi eşleşme (D yazınca Dg içeren sonuçlar gelsin)
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let searchLower = trimmedSearch.lowercased()
            
            filtered = filtered.filter { template in
                // Template name'de kısmi eşleşme (öncelik)
                let nameMatches = template.name.lowercased().contains(searchLower)
                
                // Diğer alanlarda kısmi eşleşme
                let descriptionMatches = template.description.lowercased().contains(searchLower)
                let categoryMatches = template.category.rawValue.lowercased().contains(searchLower)
                let tagsMatches = template.tags.contains { $0.lowercased().contains(searchLower) }
                
                return nameMatches || descriptionMatches || categoryMatches || tagsMatches
            }
        }
        
        return filtered
    }
    
    // MARK: - Helper Functions
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

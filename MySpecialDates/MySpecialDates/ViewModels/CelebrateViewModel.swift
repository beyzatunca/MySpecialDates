import Foundation
import SwiftUI
import Combine

@MainActor
class CelebrateViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var templates: [CardTemplate] = []
    @Published var customTemplates: [CardTemplate] = []
    @Published var pastCards: [CreatedCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Selected Template State
    @Published var selectedTemplate: CardTemplate?
    @Published var customMessage: String = ""
    @Published var userPhoto: UIImage?
    @Published var photoPosition: CGPoint = CGPoint(x: 200, y: 300)
    @Published var photoScale: CGFloat = 1.0
    @Published var photoRotation: Double = 0.0
    @Published var generatedAIMessage: String?
    @Published var isGeneratingMessage = false
    @Published var aiPrompt: String = ""
    @Published var isGeneratingWithPrompt = false
    
    // MARK: - Services
    private let openAIService: OpenAIServiceProtocol
    
    // MARK: - Initialization
    init(openAIService: OpenAIServiceProtocol = OpenAIService()) {
        self.openAIService = openAIService
        loadTemplates()
        loadCustomTemplates()
        loadPastCards()
    }
    
    // MARK: - Template Loading
    func loadTemplates() {
        // Try multiple paths for JSON file
        var url: URL?
        
        // Try main bundle first
        if let mainUrl = Bundle.main.url(forResource: "CardTemplateList", withExtension: "json") {
            url = mainUrl
        } else if let resourceUrl = Bundle.main.url(forResource: "CardTemplateList", withExtension: "json", subdirectory: "Resources") {
            url = resourceUrl
        } else if let resourceUrl = Bundle.main.url(forResource: "CardTemplateList", withExtension: "json", subdirectory: "MySpecialDates/Resources") {
            url = resourceUrl
        }
        
        guard let jsonUrl = url else {
            print("❌ CardTemplateList.json not found in bundle")
            errorMessage = "Template list not found in bundle"
            templates = createDefaultTemplates()
            return
        }
        
        do {
            let data = try Data(contentsOf: jsonUrl)
            templates = try JSONDecoder().decode([CardTemplate].self, from: data)
            print("✅ Loaded \(templates.count) templates from JSON")
        } catch {
            print("❌ Failed to decode templates: \(error.localizedDescription)")
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
            templates = createDefaultTemplates()
        }
    }
    
    // MARK: - Template Selection
    func selectTemplate(_ template: CardTemplate) {
        selectedTemplate = template
        customMessage = ""
        userPhoto = nil
        generatedAIMessage = nil
        aiPrompt = ""
    }
    
    // MARK: - AI Message Generation
    func generateAIMessage(for template: CardTemplate, recipientName: String? = nil) async {
        isGeneratingMessage = true
        errorMessage = nil
        
        do {
            let prompt = buildPrompt(for: template, recipientName: recipientName)
            let message = try await openAIService.generateMessage(prompt: prompt)
            generatedAIMessage = message
            customMessage = message
        } catch {
            errorMessage = "Failed to generate message: \(error.localizedDescription)"
        }
        
        isGeneratingMessage = false
    }
    
    // MARK: - AI Template Update with Prompt
    func updateTemplateWithPrompt(_ prompt: String) async {
        guard let template = selectedTemplate else { return }
        
        isGeneratingWithPrompt = true
        errorMessage = nil
        
        do {
            let fullPrompt = "Based on this card template (\(template.name)), update the message according to: \(prompt). Keep it short and personal, maximum 3 sentences."
            let message = try await openAIService.generateMessage(prompt: fullPrompt)
            customMessage = message
            generatedAIMessage = message
        } catch {
            errorMessage = "Failed to update template: \(error.localizedDescription)"
        }
        
        isGeneratingWithPrompt = false
    }
    
    private func buildPrompt(for template: CardTemplate, recipientName: String?) -> String {
        let tone = template.defaultTone.rawValue
        let category = template.category.rawValue
        let namePart = recipientName.map { " for \($0)" } ?? ""
        
        return "Write a \(tone) and personal \(category) message\(namePart). Keep it short and emotional. Maximum 3 sentences."
    }
    
    // MARK: - Photo Selection
    func setUserPhoto(_ image: UIImage?) {
        userPhoto = image
        // Reset photo position when new photo is set
        if image != nil {
            photoPosition = CGPoint(x: 200, y: 300)
            photoScale = 1.0
            photoRotation = 0.0
        }
    }
    
    func updatePhotoPosition(_ position: CGPoint, scale: CGFloat, rotation: Double) {
        photoPosition = position
        photoScale = scale
        photoRotation = rotation
    }
    
    // MARK: - Card Creation
    func createCard() -> CreatedCard? {
        guard let template = selectedTemplate else { return nil }
        
        // Kullanıcı metin eklemeden de kart oluşturabilir
        let card = CreatedCard(
            id: UUID().uuidString,
            templateId: template.id,
            message: customMessage, // Boş mesaj da kabul edilir
            userPhotoData: userPhoto?.jpegData(compressionQuality: 0.8),
            createdAt: Date(),
            templateName: template.name
        )
        
        pastCards.insert(card, at: 0)
        savePastCards()
        
        // Reset state
        selectedTemplate = nil
        customMessage = ""
        userPhoto = nil
        generatedAIMessage = nil
        aiPrompt = ""
        
        return card
    }
    
    // MARK: - Past Cards Management
    func loadPastCards() {
        if let data = UserDefaults.standard.data(forKey: "pastCards"),
           let cards = try? JSONDecoder().decode([CreatedCard].self, from: data) {
            pastCards = cards
        }
    }
    
    func savePastCards() {
        if let data = try? JSONEncoder().encode(pastCards) {
            UserDefaults.standard.set(data, forKey: "pastCards")
        }
    }
    
    func deleteCard(_ card: CreatedCard) {
        pastCards.removeAll { $0.id == card.id }
        savePastCards()
    }
    
    // MARK: - Custom Templates Management
    func loadCustomTemplates() {
        if let data = UserDefaults.standard.data(forKey: "customTemplates"),
           let templates = try? JSONDecoder().decode([CardTemplate].self, from: data) {
            customTemplates = templates
            print("✅ Loaded \(customTemplates.count) custom templates")
        }
    }
    
    func saveCustomTemplates() {
        if let data = try? JSONEncoder().encode(customTemplates) {
            UserDefaults.standard.set(data, forKey: "customTemplates")
            print("✅ Saved \(customTemplates.count) custom templates")
        }
    }
    
    func addCustomTemplate(_ template: CardTemplate) {
        customTemplates.append(template)
        saveCustomTemplates()
    }
    
    func updateCustomTemplate(_ template: CardTemplate) {
        if let index = customTemplates.firstIndex(where: { $0.id == template.id }) {
            customTemplates[index] = template
            saveCustomTemplates()
        }
    }
    
    func deleteCustomTemplate(_ template: CardTemplate) {
        customTemplates.removeAll { $0.id == template.id }
        saveCustomTemplates()
    }
    
    // MARK: - Default Templates (Fallback)
    private func createDefaultTemplates() -> [CardTemplate] {
        return [
            CardTemplate(
                id: "default-1",
                name: "Classic Birthday",
                previewImageName: "default_preview",
                backgroundImageName: "default_bg",
                supportsUserPhoto: false,
                defaultTone: .sweet,
                category: .birthday,
                description: "A simple birthday card.",
                tags: ["default", "birthday"]
            ),
            CardTemplate(
                id: "default-2",
                name: "Romantic Card",
                previewImageName: "default_preview",
                backgroundImageName: "default_bg",
                supportsUserPhoto: true,
                defaultTone: .romantic,
                category: .anniversary,
                description: "A romantic card for special moments.",
                tags: ["default", "romantic"]
            )
        ]
    }
}

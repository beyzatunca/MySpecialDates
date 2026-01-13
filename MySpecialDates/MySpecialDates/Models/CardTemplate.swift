import Foundation
import UIKit

// MARK: - Card Template Model
struct CardTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let previewImageName: String
    let backgroundImageName: String
    let supportsUserPhoto: Bool
    let defaultTone: MessageTone
    let category: CardCategory
    let description: String
    let tags: [String]
    
    enum MessageTone: String, Codable, CaseIterable {
        case sweet
        case funny
        case emotional
        case casual
        case formal
        case romantic
    }
    
    enum CardCategory: String, Codable, CaseIterable {
        case birthday
        case anniversary
        case graduation
        case wedding
        case general
    }
}

// MARK: - Created Card Model
struct CreatedCard: Identifiable, Codable {
    let id: String
    let templateId: String
    let message: String
    let userPhotoData: Data?
    let createdAt: Date
    let templateName: String
    
    var userPhoto: UIImage? {
        guard let data = userPhotoData else { return nil }
        return UIImage(data: data)
    }
}


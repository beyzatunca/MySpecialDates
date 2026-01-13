import Foundation
import UIKit

/// Helper class to manage and load template images from Assets.xcassets
@MainActor
class ImageAssetHelper {
    
    /// Loads an image from Assets.xcassets by name
    /// - Parameter name: The name of the image asset (without extension)
    /// - Returns: UIImage if found, nil otherwise
    static func loadImage(named name: String) -> UIImage? {
        // Method 1: Standard Asset Catalog lookup (Image Set)
        if let image = UIImage(named: name) {
            return image
        }
        
        // Method 2: Try loading from main bundle (if images are added as resources)
        // Note: Images in Assets.xcassets must be Image Sets to be included in bundle
        // This method tries to find images that might be added as bundle resources
        if let bundlePath = Bundle.main.path(forResource: name, ofType: "jpg") {
            if let image = UIImage(contentsOfFile: bundlePath) {
                print("✅ Loaded image from bundle: \(name).jpg")
                return image
            }
        }
        
        // Method 3: Try loading from bundle resources (anywhere in bundle)
        let extensions = ["png", "jpg", "jpeg", "PNG", "JPG", "JPEG"]
        for ext in extensions {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: ext) {
                if let image = UIImage(contentsOfFile: bundlePath) {
                    print("✅ Loaded image from bundle: \(name).\(ext)")
                    return image
                }
            }
        }
        
        // Method 4: Try with different case variations for Asset Catalog
        let variations = [
            name,
            name.lowercased(),
            name.uppercased(),
            name.capitalized,
            name.replacingOccurrences(of: "-", with: "_"),
            name.replacingOccurrences(of: "_", with: "-")
        ]
        
        for imageName in variations {
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        // Method 5: Try loading from Assets.xcassets with different extensions
        if let assetsPath = Bundle.main.path(forResource: "Assets", ofType: "xcassets") {
            for ext in ["jpg", "jpeg", "png", "JPG", "JPEG", "PNG"] {
                let imagePath = (assetsPath as NSString).appendingPathComponent("\(name).\(ext)")
                if FileManager.default.fileExists(atPath: imagePath) {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        print("✅ Loaded image from Assets.xcassets: \(name).\(ext)")
                        return image
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Checks if an image exists in Assets.xcassets
    /// - Parameter name: The name of the image asset
    /// - Returns: true if image exists, false otherwise
    static func imageExists(named name: String) -> Bool {
        return loadImage(named: name) != nil
    }
    
    /// Gets all available image names from Assets.xcassets (limited functionality)
    /// Note: This is a helper method that can be extended to list all assets
    static func listAvailableImages() -> [String] {
        // This would require accessing the asset catalog directly
        // For now, return common template names
        return [
            "animal-themed",
            "baloon-themed",
            "bowling-themed",
            "candle-themed",
            "hand-drawed-black-themed"
        ]
    }
}


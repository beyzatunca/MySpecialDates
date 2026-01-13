import SwiftUI

struct GiftCardsView: View {
    let event: UserEvent
    @Environment(\.dismiss) private var dismiss
    
    let giftCardBrands = [
        GiftCardBrand(name: "Zara", icon: "🛍️", color: Color.black),
        GiftCardBrand(name: "H&M", icon: "👕", color: Color.red),
        GiftCardBrand(name: "Amazon", icon: "📦", color: Color.orange),
        GiftCardBrand(name: "Apple", icon: "🍎", color: Color.gray)
    ]
    
    var body: some View {
        NavigationStack {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Send Gift Card")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("For: \(event.displayName)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Gift Card Brands
                        VStack(spacing: 16) {
                            ForEach(giftCardBrands) { brand in
                                Button(action: {
                                    openGiftCardWebsite(brand: brand)
                                }) {
                                    HStack(spacing: 16) {
                                        Text(brand.icon)
                                            .font(.system(size: 40))
                                        
                                        Text(brand.name)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(20)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle())
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
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func openGiftCardWebsite(brand: GiftCardBrand) {
        var urlString = ""
        switch brand.name {
        case "Zara":
            urlString = "https://www.zara.com"
        case "H&M":
            urlString = "https://www.hm.com"
        case "Amazon":
            urlString = "https://www.amazon.com/gift-cards"
        case "Apple":
            urlString = "https://www.apple.com/shop/gift-cards"
        default:
            return
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct GiftCardBrand: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}


import SwiftUI

struct CharityView: View {
    let event: UserEvent
    @Environment(\.dismiss) private var dismiss
    
    let charities = [
        Charity(name: "UNICEF", description: "United Nations Children's Fund", icon: "🌍", website: "https://www.unicef.org"),
        Charity(name: "WWF", description: "World Wide Fund for Nature", icon: "🐼", website: "https://www.worldwildlife.org"),
        Charity(name: "Kızılay", description: "Turkish Red Crescent", icon: "❤️", website: "https://www.kizilay.org.tr")
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
                            Text("Do Charity")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Make a donation in honor of \(event.displayName)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        
                        // Charities List
                        VStack(spacing: 16) {
                            ForEach(charities) { charity in
                                Button(action: {
                                    openCharityWebsite(charity: charity)
                                }) {
                                    HStack(spacing: 16) {
                                        Text(charity.icon)
                                            .font(.system(size: 40))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(charity.name)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.primary)
                                            
                                            Text(charity.description)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                        
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
    
    private func openCharityWebsite(charity: Charity) {
        if let url = URL(string: charity.website) {
            UIApplication.shared.open(url)
        }
    }
}

struct Charity: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let website: String
}


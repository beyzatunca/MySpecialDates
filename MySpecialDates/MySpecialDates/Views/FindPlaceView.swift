import SwiftUI

struct FindPlaceView: View {
    let event: UserEvent
    @Environment(\.dismiss) private var dismiss
    @State private var places: [Place] = []
    @State private var selectedPlace: Place? = nil
    
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
                            Text("Find a Place to Celebrate")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("For: \(event.displayName)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Places List
                        VStack(spacing: 16) {
                            ForEach(places) { place in
                                PlaceCard(place: place)
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
            .onAppear {
                loadPlaces()
            }
        }
    }
    
    private func loadPlaces() {
        // Sample places - In a real app, you would fetch from a location service
        places = [
            Place(
                name: "The Grand Restaurant",
                type: "Restaurant",
                location: "Istanbul, Turkey",
                phone: "+90 212 555 1234",
                website: "https://www.thegrandrestaurant.com"
            ),
            Place(
                name: "Sky Lounge",
                type: "Bar & Lounge",
                location: "Istanbul, Turkey",
                phone: "+90 212 555 5678",
                website: "https://www.skylounge.com"
            ),
            Place(
                name: "Celebration Hall",
                type: "Event Venue",
                location: "Istanbul, Turkey",
                phone: "+90 212 555 9012",
                website: "https://www.celebrationhall.com"
            )
        ]
    }
}

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let location: String
    let phone: String
    let website: String
}

struct PlaceCard: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(place.type)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.accentColor)
                Text(place.location)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.accentColor)
                Text(place.phone)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .foregroundColor(.accentColor)
                Link(place.website, destination: URL(string: place.website)!)
                    .font(.system(size: 14))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Ana Sayfa")
                .tabItem {
                    Image(systemName: "house")
                    Text("Ana Sayfa")
                }
            
            EventsListView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Etkinlikler")
                }
            
            Text("Kişiler")
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Kişiler")
                }
            
            Text("Profil")
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profil")
                }
        }
    }
}

#Preview {
    ContentView()
}

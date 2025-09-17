import SwiftUI

struct MainCalendarView: View {
    @State private var selectedTab = "Today"
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Date Navigation
                        dateNavigationView
                        
                        // Today Birthdays Card
                        todayBirthdaysCard
                        
                        // Upcoming Birthdays
                        upcomingBirthdaysSection
                        
                        Spacer(minLength: 100) // Tab bar için boşluk
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Custom Tab Bar
                customTabBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi Tim, here are the today's updates:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("Calendar")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Profile Button
            Button(action: {
                // TODO: Profile action
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Date Navigation
    private var dateNavigationView: some View {
        HStack {
            // Tab Buttons
            HStack(spacing: 0) {
                ForEach(["Today", "Week", "Month", "Year"], id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .white : .secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ? Color.blue : Color.clear
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(25)
            
            Spacer()
        }
    }
    
    // MARK: - Date Header
    private var dateHeaderView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("12.July")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Monday")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("13.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // MARK: - Today Birthdays Card
    private var todayBirthdaysCard: some View {
        VStack {
            dateHeaderView
            
            VStack(spacing: 20) {
                // Birthday Card
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 160)
                    
                    // Background Icons
                    HStack {
                        VStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.3))
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 25))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        
                        Spacer()
                        
                        // Balloons
                        VStack {
                            HStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 20, height: 20)
                                Circle()
                                    .fill(Color.pink)
                                    .frame(width: 25, height: 25)
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 18, height: 18)
                            }
                            .offset(y: -10)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        VStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.2))
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 35))
                                .foregroundColor(.white.opacity(0.25))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Main Content
                    VStack(spacing: 12) {
                        Text("Today Birthdays")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("No birthdays today.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    // MARK: - Upcoming Birthdays
    private var upcomingBirthdaysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming birthdays")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                // Alice Caroll
                upcomingBirthdayRow(
                    name: "Alice Caroll",
                    day: "20",
                    month: "July",
                    backgroundColor: Color.pink.opacity(0.3),
                    emoji: "👩🏾‍💼"
                )
                
                // Dad
                upcomingBirthdayRow(
                    name: "Dad",
                    day: "31",
                    month: "July", 
                    backgroundColor: Color.orange.opacity(0.3),
                    emoji: "👨🏻‍🦳"
                )
            }
        }
    }
    
    // MARK: - Upcoming Birthday Row
    private func upcomingBirthdayRow(name: String, day: String, month: String, backgroundColor: Color, emoji: String) -> some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                
                Text(emoji)
                    .font(.system(size: 30))
            }
            
            // Name and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(day)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(month)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .offset(y: -4)
                }
            }
            
            Spacer()
            
            // More Button
            Button(action: {
                // TODO: More options
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack {
            // Home Tab
            VStack(spacing: 4) {
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text("Home")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Add Birthday Tab
            VStack(spacing: 4) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                
                Text("Add birthday")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Notifications Tab
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: "bell")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    // Notification badge
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 8, y: -8)
                }
                
                Text("Notifications")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

#Preview {
    MainCalendarView()
}

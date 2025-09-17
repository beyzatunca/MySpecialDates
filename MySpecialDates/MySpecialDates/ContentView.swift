import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                DummyMainCalendarView()
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
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
            
            Text("Etkinlikler")
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

// MARK: - Dummy Main Calendar View
struct DummyMainCalendarView: View {
    @State private var selectedTab = "Today"
    @State private var currentDayOffset = 0 // 0 = 12.July, 1 = 13.July, etc.
    @State private var selectedDate: Date? = nil
    @State private var showingEventDetail = false
    @State private var weekOffset = 0 // 0 = current week, -1 = previous week, 1 = next week
    @State private var monthOffset = 0 // 0 = current month, -1 = previous month, 1 = next month
    @State private var yearOffset = 0 // 0 = current year, -1 = previous year, 1 = next year
    
    // Computed properties for dynamic content
    private var currentDateInfo: (day: String, month: String, weekday: String) {
        switch currentDayOffset {
        case 0:
            return ("12", "July", "Monday")
        case 1:
            return ("13", "July", "Tuesday")
        case 2:
            return ("14", "July", "Wednesday")
        default:
            return ("12", "July", "Monday")
        }
    }
    
    private var cardGradientColors: [Color] {
        switch currentDayOffset {
        case 0:
            return [Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.8), Color(red: 0.25, green: 0.35, blue: 0.45)]
        case 1:
            return [Color.purple.opacity(0.8), Color.purple]
        case 2:
            return [Color.green.opacity(0.8), Color.green]
        default:
            return [Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.8), Color(red: 0.25, green: 0.35, blue: 0.45)]
        }
    }
    
    // Mock events for each day
    private var todaysEvents: [(name: String, emoji: String, time: String)] {
        switch currentDayOffset {
        case 0:
            return [] // No events for 12.July
        case 1:
            return [("Alice's Birthday", "🎂", "Today")] // Event for 13.July
        case 2:
            return [("Wedding Anniversary", "💍", "Today")] // Event for 14.July
        default:
            return []
        }
    }
    
    private var hasEventsToday: Bool {
        return !todaysEvents.isEmpty
    }
    
    // Week view properties
    private var weekDates: [Date] {
        let calendar = Calendar.current
        
        // Use July 2024 as base for dummy events (15-21 July 2024)
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 15  // Start from Monday, July 15, 2024
        
        let baseStartDate = calendar.date(from: components) ?? Date()
        
        // Apply week offset to get different weeks
        let startDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseStartDate) ?? baseStartDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startDate)
        }
    }
    
    private func hasEvent(for date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        // Mock events for specific dates in July 2024
        return (day == 13 && month == 7) || 
               (day == 14 && month == 7) ||
               (day == 17 && month == 7) ||
               (day == 19 && month == 7) ||
               (day == 21 && month == 7)
    }
    
    private func getEvent(for date: Date) -> (name: String, emoji: String, time: String)? {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        // Mock events for July 2024
        switch (day, month) {
        case (13, 7):
            return ("Alice's Birthday", "🎂", "Today")
        case (14, 7):
            return ("Wedding Anniversary", "💍", "Today")
        case (17, 7):
            return ("Sarah's Graduation", "🎓", "Today")
        case (19, 7):
            return ("Beach Party", "🏖️", "Today")
        case (21, 7):
            return ("Movie Night", "🎬", "Today")
        default:
            return nil
        }
    }
    
    private func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
    
    private var weekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        if let firstDate = weekDates.first {
            return formatter.string(from: firstDate)
        }
        return "July 2024"
    }
    
    // Month view properties
    private var currentMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 7  // July 2024 as base
        components.day = 1
        
        let baseDate = calendar.date(from: components) ?? Date()
        return calendar.date(byAdding: .month, value: monthOffset, to: baseDate) ?? baseDate
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var monthDates: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<32
        
        // Get the first day of the month's weekday (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstMondayOffset = (firstWeekday == 1) ? 6 : firstWeekday - 2  // Convert to Monday-first (0 = Monday)
        
        var dates: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 0..<firstMondayOffset {
            dates.append(nil)
        }
        
        // Add all days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Fill remaining cells to complete the grid (42 cells = 6 weeks * 7 days)
        while dates.count < 42 {
            dates.append(nil)
        }
        
        return dates
    }
    
    // Year view properties
    private var currentYear: Int {
        return 2024 + yearOffset
    }
    
    private var yearTitle: String {
        return "\(currentYear)"
    }
    
    private var yearMonths: [(month: String, number: Int, hasEvents: Bool)] {
        let monthNames = ["January", "February", "March", "April", "May", "June",
                         "July", "August", "September", "October", "November", "December"]
        
        return monthNames.enumerated().map { index, name in
            let monthNumber = index + 1
            let hasEvents = hasEventsInMonth(year: currentYear, month: monthNumber)
            return (month: name, number: monthNumber, hasEvents: hasEvents)
        }
    }
    
    private func hasEventsInMonth(year: Int, month: Int) -> Bool {
        // Check if any day in this month has events
        // For now, only July 2024 has events
        return year == 2024 && month == 7
    }
    
    private func getMiniCalendarDay(week: Int, day: Int, month: Int, year: Int) -> Int {
        // Realistic mini calendar for July 2024
        if year == 2024 && month == 7 {
            // July 2024: 1st = Monday
            // Real July 2024 calendar positions:
            // Week 0: 1  2  3  4  5  6  7
            // Week 1: 8  9 10 11 12 13 14
            // Week 2: 15 16 17 18 19 20 21
            // Week 3: 22 23 24 25 26 27 28
            let dayNumber = week * 7 + day + 1
            return (dayNumber <= 31) ? dayNumber : 0
        }
        
        // For other months, show a generic pattern
        let dayNumber = week * 7 + day + 1
        return (dayNumber <= 30) ? dayNumber : 0
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func getDateTextColor(date: Date, hasEvent: Bool) -> Color {
        if isDateSelected(date) {
            return .white
        } else if hasEvent {
            return .white
        } else {
            return .primary
        }
    }
    
    private func getIndicatorColor(date: Date, hasEvent: Bool) -> Color {
        if isDateSelected(date) || hasEvent {
            return .white
        } else {
            return .clear
        }
    }
    
    private func getDateBackgroundColor(date: Date, hasEvent: Bool) -> Color {
        if isDateSelected(date) {
            return Color.orange // Selected day color
        } else if hasEvent {
            return Color(red: 0.25, green: 0.35, blue: 0.45) // Event day color
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calendar")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                }
                
                Spacer()
                
                // Profile Button
                Button(action: {
                    // TODO: Profile action
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Main Content
            ScrollView {
                VStack(spacing: 20) {
                    // Tab Selection
                    HStack {
                        HStack(spacing: 0) {
                            ForEach(["Today", "Week", "Month", "Year"], id: \.self) { tab in
                                Button(action: {
                                    selectedTab = tab
                                }) {
                                    Text(tab)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedTab == tab ? .white : .secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedTab == tab ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.clear
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Main Content based on selected tab
                    if selectedTab == "Today" {
                        // Date Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(currentDateInfo.day).\(currentDateInfo.month)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(currentDateInfo.weekday)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Today Birthdays Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: cardGradientColors),
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
                                            .fill(Color.white.opacity(0.4))
                                            .frame(width: 12, height: 12)
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 8, height: 8)
                                    }
                                    Spacer()
                                    HStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 10, height: 10)
                                        Circle()
                                            .fill(Color.white.opacity(0.25))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            .padding(.horizontal, 20)
                            
                            // Main Content
                            VStack(spacing: 12) {
                                Text("Let's Celebrate Today!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                if hasEventsToday {
                                    VStack(spacing: 8) {
                                        ForEach(Array(todaysEvents.enumerated()), id: \.offset) { _, event in
                                            HStack(spacing: 12) {
                                                Text(event.emoji)
                                                    .font(.system(size: 24))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(event.name)
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.white)
                                                    
                                                    Text(event.time)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    Text("A quiet day today ☕️")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Today's Celebrations (only show if there are events)
                        if hasEventsToday {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Today's Celebrations")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            
                                VStack(spacing: 12) {
                                    ForEach(Array(todaysEvents.enumerated()), id: \.offset) { _, event in
                                        HStack(spacing: 16) {
                                            // Event Icon
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.blue.opacity(0.2))
                                                    .frame(width: 60, height: 60)
                                                
                                                Text(event.emoji)
                                                    .font(.system(size: 30))
                                            }
                                            
                                            // Event Details
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(event.name)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                
                                                HStack(alignment: .bottom, spacing: 4) {
                                                    Text(currentDateInfo.day)
                                                        .font(.system(size: 32, weight: .bold))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(currentDateInfo.month)
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
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else if selectedTab == "Week" {
                        // Modern Week Calendar View
                        VStack(spacing: 24) {
                            // Month/Year Header with Navigation
                            HStack {
                                // Previous Week Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        weekOffset -= 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                // Week Title
                                Text(weekTitle)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Next Week Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        weekOffset += 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Week Calendar Card
                            VStack(spacing: 0) {
                                // Week days header (abbreviated)
                                HStack(spacing: 0) {
                                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                // Week dates
                                HStack(spacing: 0) {
                                    ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                                        let calendar = Calendar.current
                                        let day = calendar.component(.day, from: date)
                                        let hasEventForDate = hasEvent(for: date)
                                        
                                        Button(action: {
                                            selectedDate = date
                                            showingEventDetail = true
                                        }) {
                                            VStack(spacing: 8) {
                                                // Date number
                                                Text("\(day)")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(getDateTextColor(date: date, hasEvent: hasEventForDate))
                                                
                                                // Event indicator
                                                Circle()
                                                    .fill(getIndicatorColor(date: date, hasEvent: hasEventForDate))
                                                    .frame(width: 6, height: 6)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 60)
                                            .background(getDateBackgroundColor(date: date, hasEvent: hasEventForDate))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            
                            // Selected Date Content
                            if let selectedDate = selectedDate, showingEventDetail {
                                if let event = getEvent(for: selectedDate) {
                                    // Event Card - Modern Design
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Today's Celebrations")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            
                                            Button(action: {
                                                showingEventDetail = false
                                                self.selectedDate = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        // Event Card
                                        HStack(spacing: 16) {
                                            // Large Event Icon
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.blue.opacity(0.15))
                                                    .frame(width: 80, height: 80)
                                                
                                                Text(event.emoji)
                                                    .font(.system(size: 40))
                                            }
                                            
                                            // Event Details
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(event.name)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.primary)
                                                
                                                let calendar = Calendar.current
                                                let day = calendar.component(.day, from: selectedDate)
                                                let monthName = calendar.monthSymbols[calendar.component(.month, from: selectedDate) - 1]
                                                
                                                HStack(alignment: .bottom, spacing: 6) {
                                                    Text("\(day)")
                                                        .font(.system(size: 36, weight: .bold))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(monthName)
                                                        .font(.system(size: 18, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                        .offset(y: -6)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // More Button
                                            Button(action: {
                                                // TODO: More options
                                            }) {
                                                Image(systemName: "ellipsis")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                    .rotationEffect(.degrees(90))
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 20)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        .padding(.horizontal, 20)
                                    }
                                } else {
                                    // No event card
                                    VStack(spacing: 16) {
                                        HStack {
                                            Text("Selected Day")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            
                                            Button(action: {
                                                showingEventDetail = false
                                                self.selectedDate = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        VStack(spacing: 12) {
                                            Text("A quiet day today ☕️")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 30)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else if selectedTab == "Month" {
                        // Month Calendar View
                        VStack(spacing: 24) {
                            // Month/Year Header with Navigation
                            HStack {
                                // Previous Month Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        monthOffset -= 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                // Month Title
                                Text(monthTitle)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Next Month Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        monthOffset += 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Month Calendar Grid
                            VStack(spacing: 0) {
                                // Week days header
                                HStack(spacing: 0) {
                                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                // Calendar Grid (6 weeks x 7 days)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                    ForEach(Array(monthDates.enumerated()), id: \.offset) { index, date in
                                        if let date = date {
                                            let calendar = Calendar.current
                                            let day = calendar.component(.day, from: date)
                                            let hasEventForDate = hasEvent(for: date)
                                            
                                            Button(action: {
                                                selectedDate = date
                                                showingEventDetail = true
                                            }) {
                                                VStack(spacing: 4) {
                                                    Text("\(day)")
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(getDateTextColor(date: date, hasEvent: hasEventForDate))
                                                    
                                                    // Event indicator
                                                    Circle()
                                                        .fill(hasEventForDate ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.clear)
                                                        .frame(width: 4, height: 4)
                                                }
                                                .frame(width: 40, height: 40)
                                                .background(getDateBackgroundColor(date: date, hasEvent: hasEventForDate))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            // Empty cell for days outside the month
                                            Rectangle()
                                                .fill(Color.clear)
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            
                            // Selected Date Content (same as Week view)
                            if let selectedDate = selectedDate, showingEventDetail {
                                if let event = getEvent(for: selectedDate) {
                                    // Event Card - Modern Design
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Today's Celebrations")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            
                                            Button(action: {
                                                showingEventDetail = false
                                                self.selectedDate = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        // Event Card
                                        HStack(spacing: 16) {
                                            // Large Event Icon
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.blue.opacity(0.15))
                                                    .frame(width: 80, height: 80)
                                                
                                                Text(event.emoji)
                                                    .font(.system(size: 40))
                                            }
                                            
                                            // Event Details
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(event.name)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.primary)
                                                
                                                let calendar = Calendar.current
                                                let day = calendar.component(.day, from: selectedDate)
                                                let monthName = calendar.monthSymbols[calendar.component(.month, from: selectedDate) - 1]
                                                
                                                HStack(alignment: .bottom, spacing: 6) {
                                                    Text("\(day)")
                                                        .font(.system(size: 36, weight: .bold))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(monthName)
                                                        .font(.system(size: 18, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                        .offset(y: -6)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // More Button
                                            Button(action: {
                                                // TODO: More options
                                            }) {
                                                Image(systemName: "ellipsis")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.secondary)
                                                    .rotationEffect(.degrees(90))
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 20)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        .padding(.horizontal, 20)
                                    }
                                } else {
                                    // No event card
                                    VStack(spacing: 16) {
                                        HStack {
                                            Text("Selected Day")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            
                                            Button(action: {
                                                showingEventDetail = false
                                                self.selectedDate = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        VStack(spacing: 12) {
                                            Text("A quiet day today ☕️")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 30)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else if selectedTab == "Year" {
                        // Year View
                        VStack(spacing: 24) {
                            // Year Header with Navigation
                            HStack {
                                // Previous Year Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        yearOffset -= 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                // Year Title
                                Text(yearTitle)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Next Year Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        yearOffset += 1
                                        selectedDate = nil
                                        showingEventDetail = false
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Year Calendar Grid (3x4 months)
                            VStack(spacing: 0) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                                    ForEach(Array(yearMonths.enumerated()), id: \.offset) { index, monthInfo in
                                        Button(action: {
                                            // Navigate to month view with this month
                                            selectedTab = "Month"
                                            monthOffset = monthInfo.number - 7 // Adjust to July 2024 base
                                        }) {
                                            VStack(spacing: 12) {
                                                // Month Name
                                                Text(monthInfo.month)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                
                                                // Mini Calendar Representation
                                                VStack(spacing: 4) {
                                                    // Week header
                                                    HStack(spacing: 0) {
                                                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                                                            Text(day)
                                                                .font(.system(size: 8, weight: .medium))
                                                                .foregroundColor(.secondary)
                                                                .frame(width: 10, height: 10)
                                                        }
                                                    }
                                                    
                                                    // Mini calendar grid (simplified and fixed)
                                                    VStack(spacing: 1) {
                                                        ForEach(0..<4, id: \.self) { week in
                                                            HStack(spacing: 0) {
                                                                ForEach(0..<7, id: \.self) { day in
                                                                    let dayNumber = getMiniCalendarDay(week: week, day: day, month: monthInfo.number, year: currentYear)
                                                                    let hasEventOnDay = monthInfo.hasEvents && (dayNumber == 13 || dayNumber == 14 || dayNumber == 17 || dayNumber == 19 || dayNumber == 21)
                                                                    
                                                                    Circle()
                                                                        .fill(dayNumber > 0 ? (hasEventOnDay ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color(.systemGray5)) : Color.clear)
                                                                        .frame(width: 6, height: 6)
                                                                        .frame(width: 10, height: 6) // Container frame for alignment
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // Event indicator
                                                if monthInfo.hasEvents {
                                                    Circle()
                                                        .fill(Color(red: 0.25, green: 0.35, blue: 0.45))
                                                        .frame(width: 6, height: 6)
                                                } else {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 6, height: 6)
                                                }
                                            }
                                            .frame(width: 100, height: 120)
                                            .padding(12)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100) // Tab bar için boşluk
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 { // Sağa kaydırma
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentDayOffset = min(currentDayOffset + 1, 2)
                            }
                        } else if value.translation.width > 50 { // Sola kaydırma
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentDayOffset = max(currentDayOffset - 1, 0)
                            }
                        }
                    }
            )
            
            Spacer()
            
            // Custom Tab Bar
            HStack {
                // Home Tab
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Home")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                }
                
                Spacer()
                
                // Add Birthday Tab
                VStack(spacing: 4) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    Text("Add Special Day")
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
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
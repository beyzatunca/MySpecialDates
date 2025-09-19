import SwiftUI

// MARK: - User Event Model
struct UserEvent: Identifiable, Hashable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let eventType: String
    let customName: String?
    let date: Date
    let icon: String
    
    var displayName: String {
        if let customName = customName, !customName.isEmpty {
            return customName
        } else {
            return "\(firstName) \(lastName)'s \(eventType)"
        }
    }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
    @State private var showingAddSpecialDay = false
    @State private var showingCelebrate = false
    @State private var userEvents: [UserEvent] = []
    
    init() {
        // Add some dummy events for 2025 to test the calendar
        let calendar = Calendar.current
        var dummyEvents: [UserEvent] = []
        
        // Today's event (September 17, 2025)
        if let todayEvent = calendar.date(from: DateComponents(year: 2025, month: 9, day: 17)) {
            dummyEvents.append(UserEvent(
                firstName: "Emma",
                lastName: "Wilson",
                eventType: "Birthday",
                customName: nil,
                date: todayEvent,
                icon: "🎂"
            ))
        }
        
        // Tomorrow's events (September 18, 2025) - Multiple events for testing grouping
        if let tomorrowEvent = calendar.date(from: DateComponents(year: 2025, month: 9, day: 18)) {
            // Anniversary
            dummyEvents.append(UserEvent(
                firstName: "Michael",
                lastName: "Johnson",
                eventType: "Anniversary",
                customName: nil,
                date: tomorrowEvent,
                icon: "💍"
            ))
            
            // Birthday 1
            dummyEvents.append(UserEvent(
                firstName: "Anna",
                lastName: "Smith",
                eventType: "Birthday",
                customName: nil,
                date: tomorrowEvent,
                icon: "🎂"
            ))
            
            // Birthday 2
            dummyEvents.append(UserEvent(
                firstName: "John",
                lastName: "Doe",
                eventType: "Birthday",
                customName: nil,
                date: tomorrowEvent,
                icon: "🎂"
            ))
            
            // Custom Event
            dummyEvents.append(UserEvent(
                firstName: "Team",
                lastName: "Meeting",
                eventType: "Custom",
                customName: "Project Launch",
                date: tomorrowEvent,
                icon: "🚀"
            ))
        }
        
        // This week's events
        if let weekEvent1 = calendar.date(from: DateComponents(year: 2025, month: 9, day: 19)) {
            dummyEvents.append(UserEvent(
                firstName: "Sarah",
                lastName: "Davis",
                eventType: "Custom",
                customName: "Graduation Party",
                date: weekEvent1,
                icon: "🎓"
            ))
        }
        
        if let weekEvent2 = calendar.date(from: DateComponents(year: 2025, month: 9, day: 21)) {
            dummyEvents.append(UserEvent(
                firstName: "Alex",
                lastName: "Brown",
                eventType: "Birthday",
                customName: nil,
                date: weekEvent2,
                icon: "🎂"
            ))
        }
        
        // Next week's event
        if let nextWeekEvent = calendar.date(from: DateComponents(year: 2025, month: 9, day: 25)) {
            dummyEvents.append(UserEvent(
                firstName: "Lisa",
                lastName: "Anderson",
                eventType: "Custom",
                customName: "Concert Night",
                date: nextWeekEvent,
                icon: "🎵"
            ))
        }
        
        // Next month's events (October 2025)
        if let octoberEvent1 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 5)) {
            dummyEvents.append(UserEvent(
                firstName: "David",
                lastName: "Miller",
                eventType: "Anniversary",
                customName: nil,
                date: octoberEvent1,
                icon: "💍"
            ))
        }
        
        if let octoberEvent2 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 15)) {
            dummyEvents.append(UserEvent(
                firstName: "Jessica",
                lastName: "Garcia",
                eventType: "Custom",
                customName: "Beach Party",
                date: octoberEvent2,
                icon: "🏖️"
            ))
        }
        
        // December event (for year view testing)
        if let decemberEvent = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25)) {
            dummyEvents.append(UserEvent(
                firstName: "Christmas",
                lastName: "Day",
                eventType: "Custom",
                customName: "Christmas Celebration",
                date: decemberEvent,
                icon: "🎄"
            ))
        }
        
        _userEvents = State(initialValue: dummyEvents)
    }
    
    // Computed properties for dynamic content
    private var currentDateInfo: (day: String, month: String, weekday: String) {
        let calendar = Calendar.current
        let today = Date()
        let currentDate = calendar.date(byAdding: .day, value: currentDayOffset, to: today) ?? today
        
        let day = calendar.component(.day, from: currentDate)
        let month = calendar.monthSymbols[calendar.component(.month, from: currentDate) - 1]
        let weekday = calendar.weekdaySymbols[calendar.component(.weekday, from: currentDate) - 1]
        
        return ("\(day)", month, weekday)
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
    
    // Mock events for each day + user events
    private var todaysEvents: [(name: String, emoji: String, time: String)] {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .day, value: currentDayOffset, to: Date()) ?? Date()
        
        // Get user events for current date
        let userEventsForToday = userEvents.compactMap { event -> (name: String, emoji: String, time: String)? in
            if calendar.isDate(event.date, inSameDayAs: currentDate) {
                return (event.displayName, event.icon, "Today")
            }
            return nil
        }
        
        // Only return user events (no mock events for current dates)
        return userEventsForToday
    }
    
    private var hasEventsToday: Bool {
        return !todaysEvents.isEmpty
    }
    
    // Group today's events by type
    private var groupedTodaysEvents: [(type: String, count: Int, icon: String)] {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .day, value: currentDayOffset, to: Date()) ?? Date()
        
        // Get user events for current date
        let userEventsForToday = userEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: currentDate)
        }
        
        // Group by event type
        var eventGroups: [String: (count: Int, icon: String)] = [:]
        
        for event in userEventsForToday {
            if event.eventType == "Birthday" {
                eventGroups["Birthday"] = (
                    count: (eventGroups["Birthday"]?.count ?? 0) + 1,
                    icon: "🎂"
                )
            } else if event.eventType == "Anniversary" {
                eventGroups["Anniversary"] = (
                    count: (eventGroups["Anniversary"]?.count ?? 0) + 1,
                    icon: "💍"
                )
            } else {
                // Custom events - use the specific icon
                let customKey = "Custom"
                eventGroups[customKey] = (
                    count: (eventGroups[customKey]?.count ?? 0) + 1,
                    icon: event.icon
                )
            }
        }
        
        // Convert to array and sort
        return eventGroups.map { (type, data) in
            (type: type, count: data.count, icon: data.icon)
        }.sorted { $0.type < $1.type }
    }
    
    // Week view properties
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let targetWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek) ?? startOfWeek
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: targetWeek)
        }
    }
    
    private func hasEvent(for date: Date) -> Bool {
        let calendar = Calendar.current
        
        // Check user events
        return userEvents.contains { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
    
    private func getEvent(for date: Date) -> (name: String, emoji: String, time: String)? {
        let calendar = Calendar.current
        
        // Check user events
        if let userEvent = userEvents.first(where: { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }) {
            return (userEvent.displayName, userEvent.icon, "Today")
        }
        
        return nil
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
        
        let today = Date()
        return formatter.string(from: today)
    }
    
    // Month view properties
    private var currentMonth: Date {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        return calendar.date(byAdding: .month, value: monthOffset, to: startOfMonth) ?? startOfMonth
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
        let calendar = Calendar.current
        let today = Date()
        let baseYear = calendar.component(.year, from: today)
        return baseYear + yearOffset
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
        // Check if any user events exist in this month
        return userEvents.contains { event in
            let calendar = Calendar.current
            let eventYear = calendar.component(.year, from: event.date)
            let eventMonth = calendar.component(.month, from: event.date)
            return eventYear == year && eventMonth == month
        }
    }
    
    private func getMiniCalendarDay(week: Int, day: Int, month: Int, year: Int) -> Int {
        // Create a date for the first day of the month
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let mondayOffset = (firstWeekday + 5) % 7 // Convert to Monday = 0 system
        
        // Calculate the day number for this grid position
        let gridPosition = week * 7 + day
        let dayNumber = gridPosition - mondayOffset + 1
        
        // Get the number of days in this month
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30
        
        return (dayNumber >= 1 && dayNumber <= daysInMonth) ? dayNumber : 0
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
                                    // Modern circular display with floating emojis - centered
                                    HStack(spacing: 20) {
                                        Spacer()
                                        
                                        ForEach(Array(groupedTodaysEvents.enumerated()), id: \.offset) { _, group in
                                            VStack(spacing: 6) {
                                                // Large emoji with glow effect
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.white.opacity(0.2))
                                                        .frame(width: 50, height: 50)
                                                        .blur(radius: 8)
                                                    
                                                    Circle()
                                                        .fill(Color.white.opacity(0.15))
                                                        .frame(width: 45, height: 45)
                                                    
                                                    Text(group.icon)
                                                        .font(.system(size: 24))
                                                }
                                                
                                                // Count badge below
                                                Text("\(group.count)")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 20, height: 20)
                                                    .background(Color.white.opacity(0.3))
                                                    .cornerRadius(10)
                                            }
                                        }
                                        
                                        Spacer()
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
                                            let calendar = Calendar.current
                                            let currentMonth = calendar.component(.month, from: Date())
                                            monthOffset = monthInfo.number - currentMonth
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
                                                                    let hasEventOnDay: Bool = {
                                                                        if dayNumber > 0 {
                                                                            let calendar = Calendar.current
                                                                            var components = DateComponents()
                                                                            components.year = currentYear
                                                                            components.month = monthInfo.number
                                                                            components.day = dayNumber
                                                                            if let date = calendar.date(from: components) {
                                                                                return hasEvent(for: date)
                                                                            }
                                                                        }
                                                                        return false
                                                                    }()
                                                                    
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
            HStack(spacing: 0) {
                // Home Tab
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Home")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                }
                .frame(maxWidth: .infinity)
                
                // Add Special Day Tab
                Button(action: {
                    showingAddSpecialDay = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                        
                        Text("Add Special Day")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                
                // Celebrate Tab
                Button(action: {
                    showingCelebrate = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                        
                        Text("Celebrate")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
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
        .id(userEvents.count) // Force refresh when user events change
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingAddSpecialDay) {
            AddSpecialDayView(userEvents: $userEvents)
        }
        .sheet(isPresented: $showingCelebrate) {
            CelebrateView()
        }
    }
}

// MARK: - Celebrate View
struct CelebrateView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Top Spacing
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Celebrate")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Craft the perfect birthday wish 🥳")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // Celebration Cards Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Celebration Cards")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            // Make a Wish Birthday Cake
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.95, green: 0.92, blue: 0.88))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 6) {
                                            // Birthday cake layers with candles
                                            VStack(spacing: 2) {
                                                // Candles
                                                HStack(spacing: 3) {
                                                    ForEach(0..<6, id: \.self) { _ in
                                                        VStack(spacing: 0) {
                                                            Text("🕯️")
                                                                .font(.system(size: 8))
                                                        }
                                                    }
                                                }
                                                
                                                // Cake layers
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(red: 0.8, green: 0.3, blue: 0.3))
                                                    .frame(width: 60, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(red: 0.95, green: 0.85, blue: 0.8))
                                                    .frame(width: 65, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(red: 0.9, green: 0.6, blue: 0.7))
                                                    .frame(width: 70, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(red: 0.95, green: 0.85, blue: 0.8))
                                                    .frame(width: 75, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(red: 0.9, green: 0.7, blue: 0.4))
                                                    .frame(width: 80, height: 8)
                                            }
                                            
                                            Text("MAKE A WISH")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                    )
                            }
                            
                            // Happy Anniversary
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.35, green: 0.45, blue: 0.65))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Text("WISHING YOU")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.yellow)
                                            Text("LOTS OF LOVE")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.yellow)
                                            Text("AND HAPPINESS")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.yellow)
                                            
                                            // Wedding couple on cake with balloons
                                            VStack(spacing: 2) {
                                                HStack(spacing: 8) {
                                                    Text("🎈")
                                                        .font(.system(size: 10))
                                                    HStack(spacing: 2) {
                                                        Text("👰🏻")
                                                            .font(.system(size: 12))
                                                        Text("🤵🏻")
                                                            .font(.system(size: 12))
                                                    }
                                                    Text("🎈")
                                                        .font(.system(size: 10))
                                                }
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white.opacity(0.9))
                                                    .frame(width: 50, height: 12)
                                            }
                                            
                                            Text("HAPPY")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.pink)
                                            Text("ANNIVERSARY")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.pink)
                                        }
                                    )
                            }
                            
                            // Maria's 24th Birthday (Cocktail Theme)
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            // Disco balls
                                            HStack(spacing: 8) {
                                                Text("🪩")
                                                    .font(.system(size: 16))
                                                Text("🪩")
                                                    .font(.system(size: 12))
                                            }
                                            .offset(x: 15, y: -5)
                                            
                                            Text("Maria's 24th")
                                                .font(.system(size: 11, weight: .bold, design: .serif))
                                                .foregroundColor(.black)
                                                .italic()
                                            Text("birthday")
                                                .font(.system(size: 11, weight: .bold, design: .serif))
                                                .foregroundColor(.black)
                                                .italic()
                                            
                                            // Cocktail glass with grapefruit
                                            VStack(spacing: 0) {
                                                Text("🍸")
                                                    .font(.system(size: 20))
                                                Text("🍊")
                                                    .font(.system(size: 8))
                                                    .offset(x: -8, y: -5)
                                            }
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // AI Message Generator Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("AI Message Generator")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            // TODO: AI Message Generator action
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Get a")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Personalized Message")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                    
                    // Birthday GIFs Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Birthday GIFs")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            // Happy Birthday GIF (Dark)
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Text("✨ ⭐ ✨")
                                                .font(.system(size: 16))
                                            Text("HAPPY")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("BIRTHDAY")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("✨ ⭐ ✨")
                                                .font(.system(size: 16))
                                        }
                                    )
                            }
                            
                            // Balloons (Pink)
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.9, green: 0.7, blue: 0.7))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Text("🎈🎈")
                                                .font(.system(size: 32))
                                            Text("😊 😊")
                                                .font(.system(size: 24))
                                        }
                                    )
                            }
                            
                            // Party Hat (Light Blue)
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.7, green: 0.85, blue: 0.95))
                                    .frame(height: 120)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Text("🎉")
                                                .font(.system(size: 32))
                                            Text("🎊 🎈")
                                                .font(.system(size: 24))
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.9),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Add Special Day View
struct AddSpecialDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userEvents: [UserEvent]
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedType: EventType? = nil
    @State private var showingCalendar = false
    @State private var showingCustomOccasionInput = false
    @State private var customOccasionName = ""
    @State private var selectedDate = Date()
    @State private var showingIconSelector = false
    @State private var selectedIcon = "🎉"
    
    enum EventType: CaseIterable {
        case birthday
        case anniversary
        case custom
        
        var title: String {
            switch self {
            case .birthday: return "Birthday"
            case .anniversary: return "Anniversary"
            case .custom: return "Your Own Occasion"
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .birthday: return "🎂"
            case .anniversary: return "💍"
            case .custom: return "🎉"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Top Spacing
                    Spacer()
                        .frame(height: 60)
                    
                    // Fun Header with Animation
                    VStack(spacing: 20) {
                        // Fun Icon Animation
                        HStack(spacing: 8) {
                            Text("🎉")
                                .font(.system(size: 28))
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: selectedType)
                            
                            Text("✨")
                                .font(.system(size: 24))
                                .scaleEffect(0.8)
                                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: selectedType)
                            
                            Text("🎊")
                                .font(.system(size: 26))
                                .scaleEffect(1.1)
                                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: selectedType)
                        }
                        .padding(.bottom, 8)
                        
                        VStack(alignment: .center, spacing: 12) {
                            Text("Add Special Day")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Create a new special occasion to remember ✨")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    
                    // Fun Name Fields Section
                    VStack(spacing: 24) {
                        HStack {
                            Text("👋")
                                .font(.system(size: 20))
                            Text("Who are we celebrating?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 20) {
                            // First Name with Fun Icon
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Text("🎯")
                                        .font(.system(size: 16))
                                    Text("First Name")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                TextField("Enter first name", text: $firstName)
                                    .textFieldStyle(FunTextFieldStyle())
                            }
                            
                            // Last Name with Fun Icon
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Text("📝")
                                        .font(.system(size: 16))
                                    Text("Last Name")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                TextField("Enter last name", text: $lastName)
                                    .textFieldStyle(FunTextFieldStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                    
                    // Fun Event Type Selection
                    VStack(spacing: 24) {
                        HStack {
                            Text("🎪")
                                .font(.system(size: 20))
                            Text("What kind of celebration?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            ForEach(EventType.allCases, id: \.self) { eventType in
                                FunEventTypeRow(
                                    eventType: eventType,
                                    isSelected: selectedType == eventType,
                                    showingCustomInput: showingCustomOccasionInput && eventType == .custom,
                                    customOccasionName: $customOccasionName,
                                    onTap: {
                                        withAnimation(.spring()) {
                                            if selectedType == eventType {
                                                selectedType = nil
                                                showingCustomOccasionInput = false
                                            } else {
                                                selectedType = eventType
                                                if eventType == .custom {
                                                    showingCustomOccasionInput = true
                                                } else {
                                                    showingCustomOccasionInput = false
                                                }
                                            }
                                        }
                                    },
                                    onAddTap: {
                                        if eventType == .custom && !showingCustomOccasionInput {
                                            selectedType = eventType
                                            showingCustomOccasionInput = true
                                        } else {
                                            showingCalendar = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 120)
                }
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.8),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .sheet(isPresented: $showingCalendar) {
                CalendarPickerView(
                    selectedDate: $selectedDate,
                    onDateSelected: {
                        showingCalendar = false
                        if selectedType == .custom {
                            showingIconSelector = true
                        } else {
                            // Save the event directly
                            saveEvent()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingIconSelector) {
                IconSelectorView(
                    selectedIcon: $selectedIcon,
                    onIconSelected: {
                        showingIconSelector = false
                        saveEvent()
                    }
                )
            }
        }
    }
    
    private func saveEvent() {
        guard let eventType = selectedType else { return }
        
        let finalIcon = selectedIcon.isEmpty ? eventType.defaultIcon : selectedIcon
        let customName = eventType == .custom ? customOccasionName : nil
        
        let newEvent = UserEvent(
            firstName: firstName,
            lastName: lastName,
            eventType: eventType.title,
            customName: customName,
            date: selectedDate,
            icon: finalIcon
        )
        
        userEvents.append(newEvent)
        print("✅ Event saved: \(newEvent.displayName) on \(selectedDate)")
        dismiss()
    }
}

// MARK: - Supporting Views
struct EventTypeRow: View {
    let eventType: AddSpecialDayView.EventType
    let isSelected: Bool
    let showingCustomInput: Bool
    @Binding var customOccasionName: String
    let onTap: () -> Void
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Row
            HStack(spacing: 16) {
                // Selection Circle
                Button(action: onTap) {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.gray.opacity(0.3), lineWidth: 2)
                        .fill(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45) : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .opacity(isSelected ? 1 : 0)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Event Type Title
                Text(eventType.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Add Button
                Button(action: onAddTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.25, green: 0.35, blue: 0.45))
                    .cornerRadius(20)
                }
                .disabled(!isSelected)
                .opacity(isSelected ? 1 : 0.5)
            }
            
            // Custom Occasion Input (only for Your Own Occasion)
            if showingCustomInput && eventType == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's the special day?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 40) // Align with the title
                    
                    TextField("Enter occasion name", text: $customOccasionName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding(.leading, 40) // Align with the title
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.05) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct FunTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.3),
                                Color(red: 0.35, green: 0.45, blue: 0.65).opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

struct FunEventTypeRow: View {
    let eventType: AddSpecialDayView.EventType
    let isSelected: Bool
    let showingCustomInput: Bool
    @Binding var customOccasionName: String
    let onTap: () -> Void
    let onAddTap: () -> Void
    
    private var eventIcon: String {
        switch eventType {
        case .birthday: return "🎂"
        case .anniversary: return "💍"
        case .custom: return "🎨"
        }
    }
    
    private var eventGradient: LinearGradient {
        switch eventType {
        case .birthday:
            return LinearGradient(
                colors: [Color.pink.opacity(0.8), Color.orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .anniversary:
            return LinearGradient(
                colors: [Color.red.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .custom:
            return LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Row
            HStack(spacing: 16) {
                // Fun Selection Circle with Animation
                Button(action: onTap) {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.4), lineWidth: 3)
                            .frame(width: 28, height: 28)
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: isSelected)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Event Icon
                Text(eventIcon)
                    .font(.system(size: 24))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                // Event Type Title
                Text(eventType.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Fun Add Button
                Button(action: onAddTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold))
                            .fixedSize()
                    }
                    .foregroundColor(isSelected ? Color(red: 0.25, green: 0.35, blue: 0.45) : .white.opacity(0.7))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isSelected ? Color.white : Color.white.opacity(0.2))
                    .cornerRadius(25)
                    .scaleEffect(isSelected ? 1.05 : 0.95)
                    .animation(.spring(response: 0.3), value: isSelected)
                }
                .disabled(!isSelected)
            }
            
            // Custom Occasion Input with Fun Styling
            if showingCustomInput && eventType == .custom {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text("✨")
                            .font(.system(size: 16))
                        Text("What's the special day?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.leading, 44) // Align with the title
                    
                    TextField("Enter occasion name", text: $customOccasionName)
                        .textFieldStyle(FunTextFieldStyle())
                        .padding(.leading, 44) // Align with the title
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.3), lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Date")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Choose the date for this special occasion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 20)
                
                // Selected Date Display
                VStack(spacing: 8) {
                    Text("Selected Date")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Confirm Button
                    Button(action: onDateSelected) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Confirm Date")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45))
                        .cornerRadius(12)
                    }
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

struct IconSelectorView: View {
    @Binding var selectedIcon: String
    let onIconSelected: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let availableIcons = [
        // Celebrations
        "🎉", "🎊", "🎈", "🎁", "🎂", "🍰", "🎀", "✨",
        // Love & Relationships
        "❤️", "💕", "💖", "💍", "💒", "👫", "👪", "💐",
        // Achievements
        "🏆", "🎖️", "🏅", "🎓", "📜", "⭐", "🌟", "💫",
        // Travel & Adventure
        "✈️", "🏖️", "🏔️", "🗺️", "🎒", "📸", "🌍", "🚗",
        // Work & Career
        "💼", "👔", "💻", "📊", "🎯", "🚀", "💡", "📈",
        // Health & Fitness
        "💪", "🏃", "🧘", "🏋️", "🥇", "🎾", "⚽", "🏀",
        // Food & Dining
        "🍕", "🍔", "🍣", "🍷", "☕", "🍪", "🥂", "🍾",
        // Nature & Animals
        "🌸", "🌺", "🌻", "🦋", "🐱", "🐶", "🌙", "☀️",
        // Activities
        "🎵", "🎸", "🎨", "📚", "🎭", "🎪", "🎳", "🎲"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Icon")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.45))
                    
                    Text("Choose an icon that represents your special occasion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Selected Icon Preview
                VStack(spacing: 12) {
                    Text("Selected Icon")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(selectedIcon)
                        .font(.system(size: 48))
                        .frame(width: 80, height: 80)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.3), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 20)
                
                // Icon Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Text(icon)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        selectedIcon == icon 
                                        ? Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.2)
                                        : Color(.systemGray6)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedIcon == icon 
                                                ? Color(red: 0.25, green: 0.35, blue: 0.45)
                                                : Color.clear, 
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Confirm Button
                    Button(action: onIconSelected) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Confirm Icon")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.25, green: 0.35, blue: 0.45))
                        .cornerRadius(12)
                    }
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}
//
//  MainDashboardView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

//
//  MainDashboardView.swift
//  test project
//
//  Created by Sandun Sahiru on 2025-03-06.
//

//
//  MainDashboardView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

import SwiftUI
import Charts

// MARK: - Models
struct HealthMetric: Identifiable {
    var id = UUID()
    var name: String
    var value: Double
    var unit: String
    var icon: String
    var color: Color
    var trend: TrendDirection
    var normalRange: ClosedRange<Double>
}

enum TrendDirection {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "arrow.forward"
        }
    }
}

enum QuickAction: String, CaseIterable {
    case assessment = "Risk Assessment"
    case appointment = "Schedule Appointment"
    case telemedicine = "Speak to Doctor"
    case emergency = "Emergency"
    
    var title: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .assessment: return "clipboard.fill"
        case .appointment: return "calendar.badge.plus"
        case .telemedicine: return "video.fill"
        case .emergency: return "exclamationmark.shield.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .assessment: return .blue
        case .appointment: return .green
        case .telemedicine: return .purple
        case .emergency: return .red
        }
    }
}

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var time: Date
    var isCompleted: Bool = false
    var icon: String
    var color: Color
}

struct HistoricalDataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

struct EducationArticle: Identifiable {
    var id = UUID()
    var title: String
    var summary: String
    var imageURL: String
    var category: String
    var readTime: Int // in minutes
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    // MARK: - Properties
        @State private var selectedTab = 0
        @State private var showingRiskAssessment = false
        @State private var showingNotifications = false
        @State private var userRiskScore: Double = 18.5
        @State private var waterIntake: Double = 1.2
        @State private var waterGoal: Double = 2.5
        @State private var healthMetrics: [HealthMetric] = []
        @State private var dailyTasks: [Task] = []
        @State private var bloodPressureData: [HistoricalDataPoint] = []
        @State private var featuredArticle: EducationArticle?
        @State private var showEmergencyAlert = false
        
        // MARK: - Body
        var body: some View {
            TabView(selection: $selectedTab) {
                // Home Tab
                            homeView
                                .tabItem {
                                    Image(systemName: "house.fill")
                                    Text("Home")
                                }
                                .tag(0)
                            
                            // Assessment Tab
                            assessmentView
                                .tabItem {
                                    Image(systemName: "checklist")
                                    Text("Assessment")
                                }
                                .tag(1)
                            
                            // Track Tab
                            NavigationView {
                                HealthTrackingView()
                            }
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("Track")
                            }
                            .tag(2)
                            
                            // Learn Tab - Replace the placeholder with the real implementation
                            NavigationView {
                                EducationCenterView()
                            }
                            .tabItem {
                                Image(systemName: "book.fill")
                                Text("Learn")
                            }
                            .tag(3)
                            
                // Profile Tab
                    NavigationView {
                        ProfileView()
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(4)
                        }
            .accentColor(.blue)
            .onAppear {
                loadSampleData()
            }
            .sheet(isPresented: $showingRiskAssessment) {
                NavigationView {
                    RiskAssessmentView()
                        .navigationTitle("CKD Risk Assessment")
                        .navigationBarItems(trailing: Button("Close") {
                            showingRiskAssessment = false
                        })
                }
            }
            .sheet(isPresented: $showingNotifications) {
                NavigationView {
                    NotificationsView()
                        .navigationTitle("Notifications")
                        .navigationBarItems(trailing: Button("Close") {
                            showingNotifications = false
                        })
                }
            }
            .alert(isPresented: $showEmergencyAlert) {
                Alert(
                    title: Text("Emergency Contact"),
                    message: Text("Would you like to call the emergency medical services (119)?"),
                    primaryButton: .destructive(Text("Call Now")) {
                        // In a real app, this would trigger a phone call
                        print("Emergency call triggered")
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    
    // MARK: - Home View
    private var homeView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Bar
                topBar
                
                // Risk Score Card
                riskScoreCard
                
                // Quick Actions
                quickActionsRow
                
                // Health Metrics
                healthMetricsSection
                
                // Water Intake Card
                waterIntakeCard
                
                // Daily Tasks
                dailyTasksSection
                
                // Blood Pressure Graph
                bloodPressureGraph
                
                // Education Article Card
                educationArticleCard
                
                // Emergency Contact Button
                emergencyContactButton
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemBackground)) // Fixed color reference
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Assessment View (Placeholder)
    private var assessmentView: some View {
        VStack(spacing: 20) {
            Text("Risk Assessment")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Complete your CKD risk assessment to receive personalized recommendations")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Image(systemName: "clipboard.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue) // Fixed color reference
                .padding(.vertical, 30)
            
            Button(action: {
                showingRiskAssessment = true
            }) {
                Text("Start Assessment")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue) // Fixed color reference
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Fixed color reference
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Health Tracking View (Placeholder)
    private var healthTrackingView: some View {
        VStack {
            Text("Health Tracking")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Track your health metrics and symptoms")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple) // Fixed color reference
                .padding(.vertical, 30)
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Fixed color reference
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Education Center View (Placeholder)
    private var educationCenterView: some View {
        VStack {
            Text("Education Center")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Learn about CKD and kidney health")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Image(systemName: "book.fill")
                .font(.system(size: 80))
                .foregroundColor(.green) // Fixed color reference
                .padding(.vertical, 30)
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Fixed color reference
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Profile View (Placeholder)
    private var profileView: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Manage your personal information and preferences")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Image(systemName: "person.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange) // Fixed color reference
                .padding(.vertical, 30)
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Fixed color reference
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // User greeting and avatar
            HStack(spacing: 12) {
                Image("user-avatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2) // Fixed color reference
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Good morning,")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Sandun")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            // Notification button
            Button(action: {
                showingNotifications.toggle()
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Notification indicator
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Risk Score Card
    private var riskScoreCard: some View {
        VStack(spacing: 18) {
            HStack {
                Text("CKD Risk Assessment")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingRiskAssessment.toggle()
                }) {
                    Text("Update")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue) // Fixed color reference
                        .cornerRadius(20)
                }
            }
            
            HStack(alignment: .bottom, spacing: 16) {
                // Risk meter
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(userRiskScore / 100, 1.0)))
                        .stroke(
                            userRiskScore < 25 ? Color.green :
                                userRiskScore < 50 ? Color.yellow :
                                userRiskScore < 75 ? Color.orange : Color.red,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(userRiskScore))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("%")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current risk: Low")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.green)
                    
                    Text("Based on your last assessment on Mar 2, 2025")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Schedule your next checkup at Colombo General Hospital")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Quick Actions Row
    private var quickActionsRow: some View {
        HStack(spacing: 15) {
            ForEach(QuickAction.allCases, id: \.self) { action in
                quickActionButton(action)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func quickActionButton(_ action: QuickAction) -> some View {
        Button(action: {
            handleQuickAction(action)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(action.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 22))
                        .foregroundColor(action.color)
                }
                
                Text(action.title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .assessment:
            showingRiskAssessment = true
        case .appointment:
            // Handle appointment scheduling
            selectedTab = 1 // Navigate to assessment tab
        case .telemedicine:
            // Handle telemedicine consultation
            print("Telemedicine consultation requested")
        case .emergency:
            showEmergencyAlert = true
        }
    }
    
    // MARK: - Health Metrics Section
    private var healthMetricsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Health Metrics")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(healthMetrics) { metric in
                    metricCard(metric)
                }
            }
        }
    }
    
    private func metricCard(_ metric: HealthMetric) -> some View {
        let isNormal = metric.normalRange.contains(metric.value)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                Image(systemName: metric.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(metric.color)
                    .clipShape(Circle())
                
                Spacer()
                
                // Trend indicator
                HStack(spacing: 2) {
                    Image(systemName: metric.trend.icon)
                        .font(.system(size: 10))
                        .foregroundColor(isNormal ? Color.green : Color.red)
                    
                    Text(isNormal ? "Normal" : "Alert")
                        .font(.system(size: 10))
                        .foregroundColor(isNormal ? Color.green : Color.red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isNormal ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(metric.value, specifier: "%.1f")")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(metric.unit)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(15)
        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Water Intake Card
    private var waterIntakeCard: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Water Intake")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(waterIntake, specifier: "%.1f")L / \(waterGoal, specifier: "%.1f")L")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Water progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 20)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(CGFloat(waterIntake / waterGoal) * geometry.size.width, geometry.size.width), height: 20)
                    
                    // Water droplet markers
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .opacity(waterIntake >= Double(i) * (waterGoal / 5) ? 1 : 0.3)
                            .position(
                                x: CGFloat(Double(i) * (Double(geometry.size.width) / 5)) - 10,
                                y: 10
                            )
                    }
                }
            }
            .frame(height: 20)
            
            // Add water buttons
            HStack(spacing: 15) {
                ForEach([0.1, 0.25, 0.5], id: \.self) { amount in
                    Button(action: {
                        withAnimation {
                            waterIntake = min(waterIntake + amount, waterGoal)
                        }
                    }) {
                        Text("+\(amount, specifier: "%.2g")L")
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(Color.blue)
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        waterIntake = 0
                    }
                }) {
                    Text("Reset")
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(Color.gray)
                        .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Daily Tasks Section
    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Daily Health Tasks")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue) // Fixed color reference
                }
            }
            
            VStack(spacing: 12) {
                ForEach(dailyTasks.prefix(3)) { task in
                    taskRow(task)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func taskRow(_ task: Task) -> some View {
        HStack(spacing: 15) {
            // Checkbox
            Button(action: {
                // Toggle completion status
                toggleTaskCompletion(task)
            }) {
                ZStack {
                    Circle()
                        .stroke(task.color, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(task.color)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            
            // Icon
            Image(systemName: task.icon)
                .foregroundColor(task.color)
                .frame(width: 24)
            
            // Task details
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                Text(formattedTime(task.time))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Reminder bell
            Button(action: {
                // Set reminder for task
                setReminderForTask(task)
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(task.color.opacity(0.05))
        .cornerRadius(10)
    }
    
    // MARK: - Blood Pressure Graph
    private var bloodPressureGraph: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Blood Pressure Trend")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Menu {
                    Button("7 Days", action: {})
                    Button("30 Days", action: {})
                    Button("3 Months", action: {})
                } label: {
                    HStack {
                        Text("7 Days")
                            .font(.subheadline)
                            .foregroundColor(.blue) // Fixed color reference
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue) // Fixed color reference
                    }
                }
            }
            
            // Chart
            Chart {
                ForEach(bloodPressureData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("mmHg", dataPoint.value)
                    )
                    .foregroundStyle(Color.blue) // Fixed color reference
                    .interpolationMethod(.catmullRom)
                }
                
                RuleMark(y: .value("Normal", 120))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .leading) {
                        Text("120")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                
                RuleMark(y: .value("High", 140))
                    .foregroundStyle(Color.red.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .leading) {
                        Text("140")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .frame(height: 200)
            .chartYScale(domain: 80...160)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.day().month())
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Add reading button
            HStack {
                Spacer()
                
                Button(action: {
                    // Add new reading
                    addNewBloodPressureReading()
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                        
                        Text("Add Reading")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.blue) // Fixed color reference
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Education Article Card
        private var educationArticleCard: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("Today's Article")
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let article = featuredArticle {
                    VStack(alignment: .leading, spacing: 12) {
                        // Article image
                        ZStack(alignment: .bottomLeading) {
                            Image(article.imageURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(10)
                            
                            Text(article.category)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue) // Fixed color reference
                                .foregroundColor(.white)
                                .cornerRadius(5)
                                .padding(10)
                        }
                        
                        // Article title and summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(article.summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            HStack {
                                // Read time
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(article.readTime) min read")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Read more button
                                Button(action: {}) {
                                    Text("Read More")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue) // Fixed color reference
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            
                            Text("Loading article...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 40)
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        
        // MARK: - Emergency Contact Button
        private var emergencyContactButton: some View {
            Button(action: {
                showEmergencyAlert = true
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18))
                    
                    Text("Emergency Contact")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(15)
                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.vertical, 10)
        }
        
        // MARK: - Helper Methods
        
        /// Format time for display
        private func formattedTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        /// Toggle task completion status
        private func toggleTaskCompletion(_ task: Task) {
            if let index = dailyTasks.firstIndex(where: { $0.id == task.id }) {
                dailyTasks[index].isCompleted.toggle()
            }
        }
        
        /// Set reminder for task
        private func setReminderForTask(_ task: Task) {
            // In a real app, this would schedule a notification
            print("Setting reminder for task: \(task.title)")
        }
        
        /// Add new blood pressure reading
        private func addNewBloodPressureReading() {
            // In a real app, this would show a form to input a new reading
            // For demo purposes, we'll just add a random reading
            let calendar = Calendar.current
            let newReading = HistoricalDataPoint(
                date: Date(),
                value: Double.random(in: 110...145)
            )
            
            bloodPressureData.append(newReading)
            
            // Sort data by date
            bloodPressureData.sort { $0.date < $1.date }
        }
        
        // MARK: - Sample Data
        
        /// Load sample data for preview and demo purposes
        private func loadSampleData() {
            // Health metrics
            healthMetrics = [
                HealthMetric(
                    name: "Blood Pressure",
                    value: 118.0,
                    unit: "mmHg",
                    icon: "heart.fill",
                    color: .red,
                    trend: .down,
                    normalRange: 90...120
                ),
                HealthMetric(
                    name: "Blood Sugar",
                    value: 105.0,
                    unit: "mg/dL",
                    icon: "drop.fill",
                    color: .blue,
                    trend: .stable,
                    normalRange: 70...120
                ),
                HealthMetric(
                    name: "Creatinine",
                    value: 0.9,
                    unit: "mg/dL",
                    icon: "kidneys.fill",
                    color: .purple,
                    trend: .stable,
                    normalRange: 0.6...1.2
                ),
                HealthMetric(
                    name: "Weight",
                    value: 75.2,
                    unit: "kg",
                    icon: "scalemass.fill",
                    color: .green,
                    trend: .up,
                    normalRange: 60...80
                )
            ]
            
            // Daily tasks
            let calendar = Calendar.current
            let now = Date()
            
            dailyTasks = [
                Task(
                    title: "Take blood pressure medication",
                    time: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!,
                    isCompleted: true,
                    icon: "pill.fill",
                    color: .red
                ),
                Task(
                    title: "Drink 500ml water",
                    time: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                    isCompleted: false,
                    icon: "drop.fill",
                    color: .blue
                ),
                Task(
                    title: "30-minute walk",
                    time: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now)!,
                    isCompleted: false,
                    icon: "figure.walk",
                    color: .green
                ),
                Task(
                    title: "Log blood sugar reading",
                    time: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: now)!,
                    isCompleted: false,
                    icon: "waveform.path.ecg",
                    color: .orange
                )
            ]
            
            // Blood pressure data (7 days)
            bloodPressureData = (0..<7).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
                return HistoricalDataPoint(
                    date: date,
                    value: Double.random(in: 110...140)
                )
            }
            
            // Sort data by date
            bloodPressureData.sort { $0.date < $1.date }
            
            // Featured article
            featuredArticle = EducationArticle(
                title: "Understanding Kidney Function & CKD Early Signs",
                summary: "Learn how your kidneys work and how to identify early warning signs of kidney disease.",
                imageURL: "article-kidney-function",
                category: "Education",
                readTime: 5
            )
        }
    }

    // MARK: - Supporting Views

    struct RiskAssessmentView: View {
        // Risk assessment questions would be implemented here
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("Complete the following questions to assess your CKD risk")
                        .font(.headline)
                        .padding(.top)
                    
                    // Sample questions would go here
                    Group {
                        questionSection(title: "Age", systemImage: "calendar") {
                            // Age picker
                            Picker("Select your age", selection: .constant(35)) {
                                ForEach(18...100, id: \.self) { age in
                                    Text("\(age) years").tag(age)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                        
                        questionSection(title: "Do you have diabetes?", systemImage: "cross.case.fill") {
                            Picker("", selection: .constant(false)) {
                                Text("No").tag(false)
                                Text("Yes").tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        questionSection(title: "Do you have high blood pressure?", systemImage: "heart.fill") {
                            Picker("", selection: .constant(false)) {
                                Text("No").tag(false)
                                Text("Yes").tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        questionSection(title: "Family history of kidney disease?", systemImage: "person.2.fill") {
                            Picker("", selection: .constant(false)) {
                                Text("No").tag(false)
                                Text("Yes").tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    Button(action: {}) {
                        Text("Calculate Risk")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue) // Fixed color reference
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        
        private func questionSection<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .foregroundColor(.blue) // Fixed color reference
                    
                    Text(title)
                        .font(.headline)
                }
                
                content()
                    .padding(.leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground)) // Fixed color reference
            .cornerRadius(15)
        }
    }

    struct NotificationsView: View {
        // Sample notifications
        private let notifications = [
            (title: "Medication Reminder", message: "Time to take your blood pressure medication", time: "8:00 AM", isNew: true),
            (title: "Health Tip", message: "Staying hydrated helps your kidneys filter waste properly", time: "Yesterday", isNew: true),
            (title: "Appointment Reminder", message: "You have a checkup scheduled for tomorrow at Colombo General Hospital", time: "Yesterday", isNew: false),
            (title: "New Article", message: "New article on diet recommendations for kidney health", time: "2 days ago", isNew: false)
        ]
        
        var body: some View {
            List {
                ForEach(0..<notifications.count, id: \.self) { index in
                    let notification = notifications[index]
                    
                    HStack(spacing: 15) {
                        // Notification icon
                        Circle()
                            .fill(notification.isNew ? Color.blue : Color.gray.opacity(0.3)) // Fixed color reference
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(notification.title)
                                    .font(.headline)
                                    .foregroundColor(notification.isNew ? .primary : .secondary)
                                
                                Spacer()
                                
                                Text(notification.time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(notification.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

    // MARK: - Previews

    struct MainDashboardView_Previews: PreviewProvider {
        static var previews: some View {
            MainDashboardView()
                .preferredColorScheme(.light)
            
            MainDashboardView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }

//
//  HealthTrackingView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

import SwiftUI
import Charts

// MARK: - Health Tracking View
struct HealthTrackingView: View {
    // MARK: - Properties
    @State private var selectedMetric: MetricType = .bloodPressure
    @State private var showingAddMetricSheet = false
    @State private var showingInfoSheet = false
    @State private var searchText = ""
    @State private var timeRange: TimeRange = .week
    
    // Sample data
    @State private var metricData: [MetricType: [MetricReading]] = [:]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top section with heading and buttons
                headerSection
                
                // Metric selector
                metricSelectorSection
                
                // Time range selector
                timeRangeSelector
                
                // Main chart
                metricChartSection
                
                // Latest readings
                latestReadingsSection
                
                // Log buttons
                logButtonsSection
                
                // Trends and insights
                trendsSection
                
                // Related metrics
                relatedMetricsSection
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationTitle("Health Tracking")
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingAddMetricSheet) {
            AddMetricView(metricType: selectedMetric, onSave: addNewReading)
        }
        .sheet(isPresented: $showingInfoSheet) {
            MetricInfoView(metricType: selectedMetric)
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Track")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Monitor your important health metrics")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Info button
            Button(action: {
                showingInfoSheet = true
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
            
            // Settings button
            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Metric Selector Section
    private var metricSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Health Metric")
                .font(.headline)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        metricButton(metric)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func metricButton(_ metric: MetricType) -> some View {
        Button(action: {
            withAnimation {
                selectedMetric = metric
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: metric.icon)
                    .font(.system(size: 16))
                    .foregroundColor(selectedMetric == metric ? .white : metric.color)
                
                Text(metric.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(selectedMetric == metric ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                selectedMetric == metric
                ? metric.color
                : Color(UIColor.secondarySystemBackground)
            )
            .cornerRadius(20)
        }
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        HStack {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    timeRange = range
                }) {
                    Text(range.title)
                        .font(.subheadline)
                        .fontWeight(timeRange == range ? .semibold : .regular)
                        .foregroundColor(timeRange == range ? selectedMetric.color : .secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            timeRange == range
                            ? selectedMetric.color.opacity(0.1)
                            : Color.clear
                        )
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                if range != TimeRange.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Metric Chart Section
    private var metricChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart title and current value
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMetric.name)
                        .font(.headline)
                    
                    if let latestReading = getLatestReading() {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", latestReading.value))
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                            
                            Text(selectedMetric.unit)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Normal range indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(isInNormalRange() ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(isInNormalRange() ? "Normal" : "Attention")
                        .font(.caption)
                        .foregroundColor(isInNormalRange() ? .green : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    (isInNormalRange() ? Color.green : Color.red)
                        .opacity(0.1)
                )
                .cornerRadius(12)
            }
            
            // Chart
            chartView
                .frame(height: 200)
                .padding(.vertical, 10)
            
            // Normal range indicator under chart
            HStack(spacing: 0) {
                ForEach(getChartRanges(), id: \.self) { range in
                    VStack(alignment: .center, spacing: 4) {
                        Text(range.name)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(range.color)
                            .cornerRadius(8)
                        
                        Text(String(format: "%.0f-%.0f", range.range.lowerBound, range.range.upperBound))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Chart view based on selected metric
    private var chartView: some View {
        Chart {
            ForEach(getChartRanges(), id: \.self) { range in
                RectangleMark(
                    xStart: .value("Min", 0),
                    xEnd: .value("Max", getChartData().count + 1),
                    yStart: .value("Lower", range.range.lowerBound),
                    yEnd: .value("Upper", range.range.upperBound)
                )
                .foregroundStyle(range.color.opacity(0.1))
            }
            
            ForEach(getChartData()) { reading in
                LineMark(
                    x: .value("Date", reading.timeIndex),
                    y: .value(selectedMetric.name, reading.value)
                )
                .foregroundStyle(selectedMetric.color.gradient)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", reading.timeIndex),
                    y: .value(selectedMetric.name, reading.value)
                )
                .foregroundStyle(selectedMetric.color)
                .symbolSize(30)
            }
        }
        .chartYScale(domain: selectedMetric.chartRange)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisValueLabel()
                AxisGridLine()
            }
        }
    }
    
    // MARK: - Latest Readings Section
    private var latestReadingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Latest Readings")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(selectedMetric.color)
                }
            }
            
            if let readings = metricData[selectedMetric]?.prefix(3).reversed() {
                ForEach(Array(readings), id: \.id) { reading in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(reading.timestamp))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", reading.value))
                                    .font(.headline)
                                
                                Text(selectedMetric.unit)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        statusIndicator(for: reading)
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                                .padding(8)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(reading.status.color.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                Text("No readings available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Log Buttons Section
    private var logButtonsSection: some View {
        HStack(spacing: 15) {
            // Manual entry button
            Button(action: {
                showingAddMetricSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Add Reading")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(selectedMetric.color)
                .cornerRadius(15)
                .shadow(color: selectedMetric.color.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Sync device button
            Button(action: {}) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Sync Device")
                }
                .font(.headline)
                .foregroundColor(selectedMetric.color)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(selectedMetric.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(selectedMetric.color, lineWidth: 1)
                )
                .cornerRadius(15)
            }
        }
    }
    
    // MARK: - Trends Section
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Trends & Insights")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMetric.color)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(getTrendTitle())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(getTrendDescription())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recommendation")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(getRecommendation())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(16)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Related Metrics Section
    private var relatedMetricsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Related Metrics")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(getRelatedMetrics(), id: \.self) { metric in
                        relatedMetricCard(metric)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func relatedMetricCard(_ metric: MetricType) -> some View {
        Button(action: {
            selectedMetric = metric
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: metric.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(metric.color)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    // Trend indicator
                    if let trend = getMetricTrend(for: metric) {
                        Image(systemName: trend.icon)
                            .font(.system(size: 12))
                            .foregroundColor(trend.color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let latestValue = getLatestValue(for: metric) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", latestValue))
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(metric.unit)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No data")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(15)
            .frame(width: 160)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper methods
    
    // Format date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Status indicator for reading
    private func statusIndicator(for reading: MetricReading) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(reading.status.color)
                .frame(width: 8, height: 8)
            
            Text(reading.status.label)
                .font(.caption)
                .foregroundColor(reading.status.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(reading.status.color.opacity(0.1))
        .cornerRadius(12)
    }
    
    // Get latest reading for the selected metric
    private func getLatestReading() -> MetricReading? {
        return metricData[selectedMetric]?.last
    }
    
    // Check if latest reading is in normal range
    private func isInNormalRange() -> Bool {
        guard let latestReading = getLatestReading() else { return true }
        return latestReading.status == .normal
    }
    
    // Get chart data for the selected metric and time range
    private func getChartData() -> [IndexedMetricReading] {
        let readings = metricData[selectedMetric] ?? []
        let filtered = filterReadingsByTimeRange(readings)
        
        return filtered.enumerated().map { index, reading in
            IndexedMetricReading(
                id: reading.id,
                timeIndex: index + 1,
                timestamp: reading.timestamp,
                value: reading.value,
                status: reading.status
            )
        }
    }
    
    // Filter readings based on selected time range
    private func filterReadingsByTimeRange(_ readings: [MetricReading]) -> [MetricReading] {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .day:
            return readings.filter { calendar.isDateInToday($0.timestamp) }
        case .week:
            guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return readings }
            return readings.filter { $0.timestamp >= oneWeekAgo }
        case .month:
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return readings }
            return readings.filter { $0.timestamp >= oneMonthAgo }
        case .year:
            guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return readings }
            return readings.filter { $0.timestamp >= oneYearAgo }
        }
    }
    
    // Get chart ranges for the selected metric
    private func getChartRanges() -> [ChartRange] {
        switch selectedMetric {
        case .bloodPressure:
            return [
                ChartRange(name: "Low", range: 70.0...90.0, color: .blue),
                ChartRange(name: "Normal", range: 90.0...120.0, color: .green),
                ChartRange(name: "Elevated", range: 120.0...130.0, color: .yellow),
                ChartRange(name: "High", range: 130.0...180.0, color: .red)
            ]
        case .bloodSugar:
            return [
                ChartRange(name: "Low", range: 40.0...70.0, color: .blue),
                ChartRange(name: "Normal", range: 70.0...100.0, color: .green),
                ChartRange(name: "Pre-diabetic", range: 100.0...126.0, color: .yellow),
                ChartRange(name: "Diabetic", range: 126.0...200.0, color: .red)
            ]
        case .creatinine:
            return [
                ChartRange(name: "Low", range: 0.1...0.6, color: .blue),
                ChartRange(name: "Normal", range: 0.6...1.2, color: .green),
                ChartRange(name: "Elevated", range: 1.2...2.0, color: .yellow),
                ChartRange(name: "High", range: 2.0...5.0, color: .red)
            ]
        case .weight:
            // This would be personalized in a real app
            return [
                ChartRange(name: "Underweight", range: 40.0...60.0, color: .blue),
                ChartRange(name: "Normal", range: 60.0...80.0, color: .green),
                ChartRange(name: "Overweight", range: 80.0...100.0, color: .yellow),
                ChartRange(name: "Obese", range: 100.0...150.0, color: .red)
            ]
        case .waterIntake:
            return [
                ChartRange(name: "Low", range: 0.0...1.0, color: .red),
                ChartRange(name: "Medium", range: 1.0...2.0, color: .yellow),
                ChartRange(name: "Optimal", range: 2.0...3.5, color: .green),
                ChartRange(name: "High", range: 3.5...5.0, color: .blue)
            ]
        case .eGFR:
            return [
                ChartRange(name: "Stage 5", range: 0.0...15.0, color: .red),
                ChartRange(name: "Stage 4", range: 15.0...30.0, color: .orange),
                ChartRange(name: "Stage 3", range: 30.0...60.0, color: .yellow),
                ChartRange(name: "Stage 2", range: 60.0...90.0, color: .green),
                ChartRange(name: "Normal", range: 90.0...120.0, color: .blue)
            ]
        }
    }
    
    // Get trend title based on selected metric
    private func getTrendTitle() -> String {
        switch selectedMetric {
        case .bloodPressure:
            return "Your blood pressure is stable"
        case .bloodSugar:
            return "Blood sugar has improved since last week"
        case .creatinine:
            return "Creatinine levels are normal"
        case .weight:
            return "Your weight is trending upward"
        case .waterIntake:
            return "Water intake is below target"
        case .eGFR:
            return "Your kidney function is stable"
        }
    }
    
    // Get trend description based on selected metric
    private func getTrendDescription() -> String {
        switch selectedMetric {
        case .bloodPressure:
            return "Your average systolic BP is 118 mmHg, which is in the normal range. Keep up the good work!"
        case .bloodSugar:
            return "Your average blood sugar has decreased by 5% over the past week. Continue with your current diet and medication."
        case .creatinine:
            return "Your creatinine levels are within normal limits at 0.9 mg/dL, indicating good kidney function."
        case .weight:
            return "You've gained 1.2 kg in the past month. Consider reviewing your diet and exercise routine."
        case .waterIntake:
            return "You're drinking an average of 1.5L per day, which is below your target of 2.5L. Try to increase your water intake."
        case .eGFR:
            return "Your eGFR has been consistent at around 85 mL/min, which indicates good kidney function. Continue to monitor regularly."
        }
    }
    
    // Get recommendation based on selected metric
    private func getRecommendation() -> String {
        switch selectedMetric {
        case .bloodPressure:
            return "Continue with your medication regimen and consider adding daily meditation to further improve your blood pressure control."
        case .bloodSugar:
            return "Keep track of carbohydrate intake and ensure you're taking medication as prescribed. Consider testing more frequently after meals."
        case .creatinine:
            return "Maintain your current kidney-friendly diet and stay well-hydrated. Schedule your next blood test in 3 months."
        case .weight:
            return "Focus on portion control and aim for 30 minutes of moderate exercise daily. Log your meals to identify areas for improvement."
        case .waterIntake:
            return "Set reminders to drink water throughout the day. Try keeping a water bottle with you at all times and refilling it regularly."
        case .eGFR:
            return "Continue with your current kidney care plan. Avoid NSAIDs and other medications that can affect kidney function."
        }
    }
    
    // Get related metrics for the selected metric
    private func getRelatedMetrics() -> [MetricType] {
        switch selectedMetric {
        case .bloodPressure:
            return [.weight, .creatinine, .eGFR]
        case .bloodSugar:
            return [.weight, .bloodPressure, .creatinine]
        case .creatinine:
            return [.eGFR, .bloodPressure, .waterIntake]
        case .weight:
            return [.bloodPressure, .bloodSugar, .waterIntake]
        case .waterIntake:
            return [.creatinine, .eGFR, .weight]
        case .eGFR:
            return [.creatinine, .bloodPressure, .waterIntake]
        }
    }
    
    // Get latest value for a specific metric
    private func getLatestValue(for metric: MetricType) -> Double? {
        return metricData[metric]?.last?.value
    }
    
    // Get trend for a specific metric
    private func getMetricTrend(for metric: MetricType) -> (icon: String, color: Color)? {
        guard let readings = metricData[metric], readings.count >= 2 else {
            return nil
        }
        
        let latest = readings.last!.value
        let previous = readings[readings.count - 2].value
        
        if latest > previous {
            return (icon: "arrow.up", color: metric == .waterIntake ? .green : .red)
        } else if latest < previous {
            return (icon: "arrow.down", color: metric == .waterIntake ? .red : .green)
        } else {
            return (icon: "arrow.forward", color: .blue)
        }
    }
    
    // Add a new reading
    private func addNewReading(_ reading: MetricReading) {
        if metricData[selectedMetric] != nil {
            metricData[selectedMetric]!.append(reading)
        } else {
            metricData[selectedMetric] = [reading]
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Blood pressure data
        var bloodPressureReadings: [MetricReading] = []
        for i in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let value = Double.random(in: 110...140)
            let status: ReadingStatus = value < 120 ? .normal : (value < 130 ? .elevated : .high)
            
            bloodPressureReadings.append(
                MetricReading(timestamp: date, value: value, status: status)
            )
        }
        metricData[.bloodPressure] = bloodPressureReadings
        
        // Blood sugar data
        var bloodSugarReadings: [MetricReading] = []
        for i in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let value = Double.random(in: 80...140)
            let status: ReadingStatus = value < 100 ? .normal : (value < 126 ? .elevated : .high)
            
            bloodSugarReadings.append(
                MetricReading(timestamp: date, value: value, status: status)
            )
        }
        metricData[.bloodSugar] = bloodSugarReadings
        
        // Creatinine data
        var creatinineReadings: [MetricReading] = []
        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i * 3, to: now)! // Less frequent readings
            let value = Double.random(in: 0.7...1.4)
            let status: ReadingStatus = value < 1.2 ? .normal : (value < 2.0 ? .elevated : .high)
            
            creatinineReadings.append(
                MetricReading(timestamp: date, value: value, status: status)
            )
        }
        metricData[.creatinine] = creatinineReadings
        
        // Weight data
                var weightReadings: [MetricReading] = []
                for i in 0..<14 {
                    let date = calendar.date(byAdding: .day, value: -i * 2, to: now)! // Every 2 days
                    let value = Double.random(in: 73.5...76.5)
                    let status: ReadingStatus = value < 80 ? .normal : (value < 90 ? .elevated : .high)
                    
                    weightReadings.append(
                        MetricReading(timestamp: date, value: value, status: status)
                    )
                }
                metricData[.weight] = weightReadings
                
                // Water intake data
                var waterIntakeReadings: [MetricReading] = []
                for i in 0..<14 {
                    let date = calendar.date(byAdding: .day, value: -i, to: now)!
                    let value = Double.random(in: 1.2...2.8)
                    let status: ReadingStatus = value < 1.5 ? .low : (value < 2.5 ? .normal : .high)
                    
                    waterIntakeReadings.append(
                        MetricReading(timestamp: date, value: value, status: status)
                    )
                }
                metricData[.waterIntake] = waterIntakeReadings
                
                // eGFR data
                var eGFRReadings: [MetricReading] = []
                for i in 0..<7 {
                    let date = calendar.date(byAdding: .day, value: -i * 7, to: now)! // Weekly readings
                    let value = Double.random(in: 70...95)
                    let status: ReadingStatus = value < 60 ? .critical : (value < 90 ? .elevated : .normal)
                    
                    eGFRReadings.append(
                        MetricReading(timestamp: date, value: value, status: status)
                    )
                }
                metricData[.eGFR] = eGFRReadings
            }
        }

        // MARK: - Supporting Views

        // MARK: - Add Metric View
        struct AddMetricView: View {
            let metricType: MetricType
            let onSave: (MetricReading) -> Void
            
            @Environment(\.presentationMode) var presentationMode
            @State private var value: Double = 0
            @State private var date: Date = Date()
            @State private var notes: String = ""
            
            var body: some View {
                NavigationView {
                    Form {
                        Section(header: Text("Reading Details")) {
                            HStack {
                                Text(metricType.name)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: metricType.icon)
                                    .foregroundColor(metricType.color)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Value")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Slider(value: $value,
                                           in: metricType.sliderRange,
                                           step: metricType.sliderStep)
                                    .accentColor(metricType.color)
                                    
                                    Text("\(value, specifier: "%.1f") \(metricType.unit)")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .frame(width: 100)
                                }
                            }
                            
                            DatePicker("Date and Time", selection: $date)
                        }
                        
                        Section(header: Text("Notes")) {
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                        }
                        
                        Section {
                            HStack {
                                Text("Reading Status")
                                Spacer()
                                statusIndicator(for: calculateStatus())
                            }
                        }
                    }
                    .onAppear {
                        // Set initial value
                        value = metricType.initialValue
                    }
                    .navigationTitle("Add \(metricType.name) Reading")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        },
                        trailing: Button("Save") {
                            let reading = MetricReading(
                                timestamp: date,
                                value: value,
                                status: calculateStatus()
                            )
                            onSave(reading)
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
            
            private func calculateStatus() -> ReadingStatus {
                switch metricType {
                case .bloodPressure:
                    return value < 120 ? .normal : (value < 130 ? .elevated : (value < 140 ? .high : .critical))
                case .bloodSugar:
                    return value < 100 ? .normal : (value < 126 ? .elevated : .high)
                case .creatinine:
                    return value < 1.2 ? .normal : (value < 2.0 ? .elevated : .high)
                case .weight:
                    // This would be personalized in a real app
                    return value < 80 ? .normal : (value < 90 ? .elevated : .high)
                case .waterIntake:
                    return value < 1.5 ? .low : (value < 3.0 ? .normal : .high)
                case .eGFR:
                    return value < 60 ? .critical : (value < 90 ? .elevated : .normal)
                }
            }
            
            private func statusIndicator(for status: ReadingStatus) -> some View {
                HStack(spacing: 4) {
                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(status.label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(status.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(status.color.opacity(0.1))
                .cornerRadius(12)
            }
        }

        // MARK: - Metric Info View
        struct MetricInfoView: View {
            let metricType: MetricType
            @Environment(\.presentationMode) var presentationMode
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header with icon
                            HStack(spacing: 16) {
                                Image(systemName: metricType.icon)
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                    .frame(width: 72, height: 72)
                                    .background(metricType.color)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metricType.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("Measured in \(metricType.unit)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 16)
                            
                            // Description
                            infoSection(title: "What is \(metricType.name)?") {
                                Text(metricType.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Normal ranges
                            infoSection(title: "Normal Ranges") {
                                ForEach(getChartRanges(), id: \.self) { range in
                                    HStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(range.color)
                                            .frame(width: 16, height: 16)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(range.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Text("\(range.range.lowerBound, specifier: "%.1f") - \(range.range.upperBound, specifier: "%.1f") \(metricType.unit)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                            
                            // Importance for CKD
                            infoSection(title: "Importance for Kidney Health") {
                                Text(metricType.importanceForCKD)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Tips
                            infoSection(title: "Tips for Management") {
                                ForEach(metricType.managementTips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(metricType.color)
                                            .font(.system(size: 16))
                                        
                                        Text(tip)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            
                            // How often to measure
                            infoSection(title: "Recommended Monitoring Frequency") {
                                Text(metricType.recommendedFrequency)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .navigationTitle("About \(metricType.name)")
                    .navigationBarItems(trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            
            private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(metricType.color)
                    
                    content()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            
            private func getChartRanges() -> [ChartRange] {
                switch metricType {
                case .bloodPressure:
                    return [
                        ChartRange(name: "Low", range: 70.0...90.0, color: .blue),
                        ChartRange(name: "Normal", range: 90.0...120.0, color: .green),
                        ChartRange(name: "Elevated", range: 120.0...130.0, color: .yellow),
                        ChartRange(name: "High", range: 130.0...180.0, color: .red)
                    ]
                case .bloodSugar:
                    return [
                        ChartRange(name: "Low", range: 40.0...70.0, color: .blue),
                        ChartRange(name: "Normal", range: 70.0...100.0, color: .green),
                        ChartRange(name: "Pre-diabetic", range: 100.0...126.0, color: .yellow),
                        ChartRange(name: "Diabetic", range: 126.0...200.0, color: .red)
                    ]
                case .creatinine:
                    return [
                        ChartRange(name: "Low", range: 0.1...0.6, color: .blue),
                        ChartRange(name: "Normal", range: 0.6...1.2, color: .green),
                        ChartRange(name: "Elevated", range: 1.2...2.0, color: .yellow),
                        ChartRange(name: "High", range: 2.0...5.0, color: .red)
                    ]
                case .weight:
                    // This would be personalized in a real app
                    return [
                        ChartRange(name: "Underweight", range: 40.0...60.0, color: .blue),
                        ChartRange(name: "Normal", range: 60.0...80.0, color: .green),
                        ChartRange(name: "Overweight", range: 80.0...100.0, color: .yellow),
                        ChartRange(name: "Obese", range: 100.0...150.0, color: .red)
                    ]
                case .waterIntake:
                    return [
                        ChartRange(name: "Low", range: 0.0...1.0, color: .red),
                        ChartRange(name: "Medium", range: 1.0...2.0, color: .yellow),
                        ChartRange(name: "Optimal", range: 2.0...3.5, color: .green),
                        ChartRange(name: "High", range: 3.5...5.0, color: .blue)
                    ]
                case .eGFR:
                    return [
                        ChartRange(name: "Stage 5", range: 0.0...15.0, color: .red),
                        ChartRange(name: "Stage 4", range: 15.0...30.0, color: .orange),
                        ChartRange(name: "Stage 3", range: 30.0...60.0, color: .yellow),
                        ChartRange(name: "Stage 2", range: 60.0...90.0, color: .green),
                        ChartRange(name: "Normal", range: 90.0...120.0, color: .blue)
                    ]
                }
            }
        }

        // MARK: - Models

        // Health Metric Types
        enum MetricType: String, CaseIterable {
            case bloodPressure = "Blood Pressure"
            case bloodSugar = "Blood Sugar"
            case creatinine = "Creatinine"
            case weight = "Weight"
            case waterIntake = "Water Intake"
            case eGFR = "eGFR"
            
            var name: String {
                return rawValue
            }
            
            var icon: String {
                switch self {
                case .bloodPressure: return "heart.fill"
                case .bloodSugar: return "drop.fill"
                case .creatinine: return "kidneys.fill"
                case .weight: return "scalemass.fill"
                case .waterIntake: return "cup.and.saucer.fill"
                case .eGFR: return "waveform.path.ecg"
                }
            }
            
            var color: Color {
                switch self {
                case .bloodPressure: return .red
                case .bloodSugar: return .blue
                case .creatinine: return .purple
                case .weight: return .green
                case .waterIntake: return .cyan
                case .eGFR: return .orange
                }
            }
            
            var unit: String {
                switch self {
                case .bloodPressure: return "mmHg"
                case .bloodSugar: return "mg/dL"
                case .creatinine: return "mg/dL"
                case .weight: return "kg"
                case .waterIntake: return "L"
                case .eGFR: return "mL/min"
                }
            }
            
            var chartRange: ClosedRange<Double> {
                switch self {
                case .bloodPressure: return 70...180
                case .bloodSugar: return 40...200
                case .creatinine: return 0...5
                case .weight: return 40...150
                case .waterIntake: return 0...5
                case .eGFR: return 0...120
                }
            }
            
            var sliderRange: ClosedRange<Double> {
                switch self {
                case .bloodPressure: return 80...180
                case .bloodSugar: return 60...200
                case .creatinine: return 0.4...4.0
                case .weight: return 40...150
                case .waterIntake: return 0...5
                case .eGFR: return 10...120
                }
            }
            
            var sliderStep: Double {
                switch self {
                case .bloodPressure: return 1.0
                case .bloodSugar: return 1.0
                case .creatinine: return 0.1
                case .weight: return 0.1
                case .waterIntake: return 0.1
                case .eGFR: return 1.0
                }
            }
            
            var initialValue: Double {
                switch self {
                case .bloodPressure: return 120.0
                case .bloodSugar: return 100.0
                case .creatinine: return 1.0
                case .weight: return 75.0
                case .waterIntake: return 2.0
                case .eGFR: return 85.0
                }
            }
            
            var description: String {
                switch self {
                case .bloodPressure:
                    return "Blood pressure is the force of blood pushing against the walls of the arteries. It's measured in millimeters of mercury (mmHg) and is recorded as two numbers: systolic over diastolic pressure."
                case .bloodSugar:
                    return "Blood sugar, or blood glucose, is the amount of glucose in your bloodstream. Glucose is the main source of energy for the body's cells and comes from the food you eat."
                case .creatinine:
                    return "Creatinine is a waste product produced by muscles. Your kidneys filter creatinine from your blood into your urine. A high level of creatinine in your blood can indicate kidney problems."
                case .weight:
                    return "Body weight is a key health indicator. For kidney patients, maintaining a healthy weight can help control blood pressure and blood sugar levels, which are important for kidney health."
                case .waterIntake:
                    return "Water intake refers to the amount of fluids consumed throughout the day. Proper hydration is essential for kidney function, as the kidneys use water to filter waste from the blood."
                case .eGFR:
                    return "Estimated Glomerular Filtration Rate (eGFR) is a test that measures how well your kidneys are filtering blood. It estimates how much blood passes through the glomeruli (tiny filters in the kidneys) each minute."
                }
            }
            
            var importanceForCKD: String {
                switch self {
                case .bloodPressure:
                    return "High blood pressure is both a cause and a complication of chronic kidney disease (CKD). Controlling blood pressure is one of the most important ways to slow the progression of kidney disease."
                case .bloodSugar:
                    return "Diabetes is the leading cause of kidney disease. Monitoring and controlling blood sugar levels can help prevent kidney damage and slow the progression of existing kidney disease."
                case .creatinine:
                    return "Creatinine levels are a key indicator of kidney function. Rising creatinine levels can indicate worsening kidney function. Regular monitoring helps track kidney health over time."
                case .weight:
                    return "Maintaining a healthy weight reduces strain on the kidneys and helps control conditions like diabetes and high blood pressure that can damage the kidneys."
                case .waterIntake:
                    return "Proper hydration supports kidney function by helping to flush toxins from the body. However, in advanced kidney disease, fluid intake may need to be limited, as directed by your healthcare provider."
                case .eGFR:
                    return "eGFR is the best overall measure of kidney function and is used to determine the stage of kidney disease. Tracking eGFR over time helps monitor the progression of kidney disease."
                }
            }
            
            var managementTips: [String] {
                switch self {
                case .bloodPressure:
                    return [
                        "Take medications as prescribed",
                        "Reduce sodium intake to less than 2g per day",
                        "Exercise regularly for 30 minutes most days",
                        "Limit alcohol consumption",
                        "Practice stress-reduction techniques like meditation"
                    ]
                case .bloodSugar:
                    return [
                        "Follow a balanced diet rich in fiber and low in simple sugars",
                        "Take medications or insulin as prescribed",
                        "Exercise regularly to improve insulin sensitivity",
                        "Monitor blood sugar levels as recommended by your doctor",
                        "Maintain a healthy weight"
                    ]
                case .creatinine:
                    return [
                        "Follow a kidney-friendly diet as recommended",
                        "Take medications as prescribed",
                        "Stay well-hydrated unless otherwise directed",
                        "Avoid NSAIDs and other medications that can harm the kidneys",
                        "Complete regular blood tests as scheduled"
                    ]
                case .weight:
                    return [
                        "Aim for a balanced diet rich in fruits, vegetables, and whole grains",
                        "Exercise regularly, including both cardiovascular and strength training",
                        "Monitor calorie intake if trying to lose weight",
                        "Weigh yourself at the same time each day for consistency",
                        "Speak with a dietitian about a personalized meal plan"
                    ]
                case .waterIntake:
                    return [
                        "Carry a water bottle with you throughout the day",
                        "Set reminders to drink water regularly",
                        "Drink a glass of water with each meal and snack",
                        "Monitor urine color as an indicator of hydration (pale yellow is ideal)",
                        "Adjust intake based on activity level and weather conditions"
                    ]
                case .eGFR:
                    return [
                        "Take all prescribed medications",
                        "Follow dietary restrictions recommended by your healthcare team",
                        "Control blood pressure and blood sugar",
                        "Avoid nephrotoxic medications",
                        "Complete all recommended lab tests to monitor kidney function"
                    ]
                }
            }
            
            var recommendedFrequency: String {
                switch self {
                case .bloodPressure:
                    return "For those with hypertension or kidney disease, blood pressure should be monitored daily, ideally at the same time each day."
                case .bloodSugar:
                    return "Testing frequency varies based on your diabetes management plan. Those on insulin may need to test 2-4 times daily, while others might test less frequently."
                case .creatinine:
                    return "Typically measured through blood tests every 3-12 months, depending on your stage of kidney disease and overall health status."
                case .weight:
                    return "Daily or weekly monitoring is recommended. Consistent timing (e.g., morning after using the bathroom and before eating) provides the most accurate tracking."
                case .waterIntake:
                    return "Daily tracking is recommended. Your target intake may vary based on your specific kidney condition, medications, and healthcare provider recommendations."
                case .eGFR:
                    return "Usually measured through blood tests every 3-12 months, with frequency increasing for more advanced kidney disease or during medication adjustments."
                }
            }
        }

        // Reading status
        enum ReadingStatus {
            case low
            case normal
            case elevated
            case high
            case critical
            
            var label: String {
                switch self {
                case .low: return "Low"
                case .normal: return "Normal"
                case .elevated: return "Elevated"
                case .high: return "High"
                case .critical: return "Critical"
                }
            }
            
            var color: Color {
                switch self {
                case .low: return .blue
                case .normal: return .green
                case .elevated: return .yellow
                case .high: return .orange
                case .critical: return .red
                }
            }
        }

        // Time range for charts
        enum TimeRange: String, CaseIterable {
            case day = "Day"
            case week = "Week"
            case month = "Month"
            case year = "Year"
            
            var title: String {
                return rawValue
            }
        }

        // Metric reading model
        struct MetricReading: Identifiable {
            var id = UUID()
            var timestamp: Date
            var value: Double
            var status: ReadingStatus
            var notes: String = ""
        }

        // Indexed reading for charts
        struct IndexedMetricReading: Identifiable {
            var id: UUID
            var timeIndex: Int
            var timestamp: Date
            var value: Double
            var status: ReadingStatus
        }

        // Chart range model
        struct ChartRange: Hashable {
            var name: String
            var range: ClosedRange<Double>
            var color: Color
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(name)
                hasher.combine(range.lowerBound)
                hasher.combine(range.upperBound)
            }
            
            static func == (lhs: ChartRange, rhs: ChartRange) -> Bool {
                return lhs.name == rhs.name &&
                       lhs.range.lowerBound == rhs.range.lowerBound &&
                       lhs.range.upperBound == rhs.range.upperBound
            }
        }

        // MARK: - Preview
        struct HealthTrackingView_Previews: PreviewProvider {
            static var previews: some View {
                NavigationView {
                    HealthTrackingView()
                }
                .preferredColorScheme(.light)
                
                NavigationView {
                    HealthTrackingView()
                }
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            }
        }

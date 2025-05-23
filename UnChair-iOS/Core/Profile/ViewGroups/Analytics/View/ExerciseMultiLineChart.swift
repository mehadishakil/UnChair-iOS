//
//  BreakMultiLineChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 8/4/25.
//
import SwiftUI
import Charts

struct ExerciseMultiLineChart: View {
    @State private var rawSelectedDate: Date?
    @State private var tappedBreakType: String?
    @Binding var currentActiveItem: ExerciseChartModel?
    @Binding var plotWidth: CGFloat
    var exerciseData: [ExerciseChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var monthlyAggregatedExerciseData: [ExerciseChartModel] = []
    
    var selectedViewItem: ExerciseChartModel? {
        guard let rawSelectedDate else { return nil }
        
        // Different granularity based on the tab
        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
        
        return exerciseChartData.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
        }
    }
    
    private var exerciseChartData: [ExerciseChartModel] {
        switch currentTab {
        case "Week":
            return exerciseData.suffix(7)
        case "Month":
            return exerciseData.suffix(30)
        case "Year":
            return monthlyAggregatedExerciseData
        default:
            return exerciseData
        }
    }
    
    // Get all unique break types regardless of data
    private var allBreakTypes: [String] {
        var types = Set<String>()
        for model in exerciseData {
            for entry in model.breakEntries {
                types.insert(entry.breakType)
            }
        }
        
        if types.isEmpty {
            types = ["Short Break", "Quick Break", "Medium Break", "Long Break"]
        }
        
        return Array(types).sorted()
    }
    
    // Create organized data points by break type
    private var organizedDataPoints: [String: [ExerciseBreakDataPoint]] {
        var organized: [String: [ExerciseBreakDataPoint]] = [:]
        
        // Initialize with empty arrays for all break types
        for breakType in allBreakTypes {
            organized[breakType] = []
        }
        
        // Add all data points
        for model in exerciseChartData {
            // Organize by break type
            let date = model.date
            let existingBreakTypes = model.breakEntries.map { $0.breakType }
            
            // Add data for existing break entries
            for entry in model.breakEntries {
                let point = ExerciseBreakDataPoint(
                    date: date,
                    breakType: entry.breakType,
                    breakValue: entry.breakValue
                )
                organized[entry.breakType, default: []].append(point)
            }
            
            // Ensure all break types have a data point for this date
            for breakType in allBreakTypes {
                if !existingBreakTypes.contains(breakType) {
                    let point = ExerciseBreakDataPoint(
                        date: date,
                        breakType: breakType,
                        breakValue: 0
                    )
                    organized[breakType, default: []].append(point)
                }
            }
        }
        
        // Sort data points by date for each break type
        for breakType in organized.keys {
            organized[breakType] = organized[breakType]?.sorted(by: { $0.date < $1.date }) ?? []
        }
        
        return organized
    }
    
    // Define colors for each break type
    private func colorForBreakType(_ type: String) -> Color {
        switch type {
        case "Long Break": return .pink
        case "Medium Break": return .green
        case "Quick Break": return .orange
        case "Short Break": return .purple
        default: return .pink
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                if let selectedItem = selectedViewItem {
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected", selectedItem.date, unit: component))
                        .foregroundStyle(.blue.gradient)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) {
                            // define a two-column layout
                            let columns = [
                              GridItem(.flexible(), spacing: 8),
                              GridItem(.flexible(), spacing: 8)
                            ]

                            VStack(spacing: 4) {
                              LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                                ForEach(selectedItem.breakEntries.sorted(by: { $0.breakType < $1.breakType }), id: \.breakType) { entry in
                                  HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                      .fill(colorForBreakType(entry.breakType))
                                      .frame(width: 12, height: 4)
                                    Text("\(entry.breakValue, specifier: "%.1f") min")
                                      .font(.caption)
                                  }
                                  .frame(maxWidth: .infinity)  // make each cell expand equally
                                }
                              }

                              // then your date label below
                              if currentTab == "Year" {
                                Text(selectedItem.date, format: .dateTime.month(.wide))
                                  .font(.caption2)
                              } else {
                                Text(selectedItem.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                  .font(.caption2)
                              }
                            }
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
                        }
                }
                
                // Chart lines grouped by break type
                ForEach(allBreakTypes, id: \.self) { breakType in
                    let dataPoints = organizedDataPoints[breakType] ?? []
                    
                    ForEach(dataPoints) { point in
                        LineMark(
                            x: .value("Date", point.date, unit: currentTab == "Year" ? .month : .day),
                            y: .value("Value", point.breakValue)
                        )
                        .foregroundStyle(colorForBreakType(breakType))
                        .lineStyle(StrokeStyle(lineWidth: breakType == tappedBreakType ? 4 : 2))
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Circle()
                                .fill(colorForBreakType(breakType))
                                .frame(width: breakType == tappedBreakType ? 10 : 6)
                        }
                        .symbolSize(breakType == tappedBreakType ? 100 : 50)
                        .opacity(tappedBreakType == nil || breakType == tappedBreakType ? 1.0 : 0.3)
                    }
                    .foregroundStyle(by: .value("Break Type", breakType))
                }
            }
            .chartForegroundStyleScale(domain: allBreakTypes, range: allBreakTypes.map { colorForBreakType($0) })
            .chartLegend(.hidden)
            .frame(height: 180)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: exerciseData) { _, newData in
                if currentTab == "Year" {
                    monthlyAggregatedExerciseData = aggregateByMonth(newData).suffix(12)
                }
            }
            .onChange(of: currentTab) { _, newValue in
                if newValue == "Year" {
                    monthlyAggregatedExerciseData = aggregateByMonth(exerciseData).suffix(12)
                }
            }
            .chartXAxis {
                if currentTab == "Year" {
                    AxisMarks(values: .stride(by: .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.narrow))
                            }
                        }
                    }
                } else if currentTab == "Week" {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                } else if currentTab == "Month" {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.day())
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            
            // Custom legend implementation
            VStack() {
                HStack {
                    HStack() {
                        legendItem(for: allBreakTypes.first ?? "Long Break")
                        if allBreakTypes.count > 3 {
                            Spacer()
                            legendItem(for: allBreakTypes[1])
                            Spacer()
                            legendItem(for: allBreakTypes[2])
                            Spacer()
                            legendItem(for: allBreakTypes[3])
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                
            }
            .padding(.top, 4)
        }
        .padding(.horizontal)
        .onAppear {
            if currentTab == "Year" && monthlyAggregatedExerciseData.isEmpty {
                monthlyAggregatedExerciseData = aggregateByMonth(exerciseData).suffix(12)
            }
        }
    }
    
    // Custom legend item for better control
    private func legendItem(for breakType: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForBreakType(breakType))
                .frame(width: 8, height: 8)
            
            Text(breakType)
                .font(.caption)
                .lineLimit(2)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(tappedBreakType == breakType ?
                      Color.gray.opacity(0.2) : Color.clear)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                if tappedBreakType == breakType {
                    tappedBreakType = nil
                } else {
                    tappedBreakType = breakType
                }
            }
        }
    }
    
    private func aggregateByMonth(_ data: [ExerciseChartModel]) -> [ExerciseChartModel] {
        let calendar = Calendar.current
        
        let groupedData = Dictionary(grouping: data) { item in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return components
        }
        
        return groupedData.map { (components, items) in
            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
            
            // Create a dictionary to hold aggregated values for each break type
            var aggregatedBreaks: [String: Double] = [:]
            var breakTypeCounts: [String: Int] = [:]
            
            // Get all unique break types from this month's data
            var allMonthBreakTypes = Set<String>()
            
            // Collect all break entries
            for item in items {
                for entry in item.breakEntries {
                    allMonthBreakTypes.insert(entry.breakType)
                    
                    if aggregatedBreaks[entry.breakType] == nil {
                        aggregatedBreaks[entry.breakType] = 0
                        breakTypeCounts[entry.breakType] = 0
                    }
                    
                    aggregatedBreaks[entry.breakType]! += entry.breakValue
                    breakTypeCounts[entry.breakType]! += 1
                }
            }
            
            // Calculate averages
            var aggregatedEntries: [BreakEntry] = []
            for (breakType, totalValue) in aggregatedBreaks {
                let count = breakTypeCounts[breakType] ?? 1
                let averageValue = totalValue / Double(count)
                aggregatedEntries.append(BreakEntry(breakType: breakType, breakValue: averageValue))
            }
            
            // Add any missing break types from the full dataset with 0 values
            for breakType in allBreakTypes {
                if !allMonthBreakTypes.contains(breakType) {
                    aggregatedEntries.append(BreakEntry(breakType: breakType, breakValue: 0))
                }
            }
            
            return ExerciseChartModel(
                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
                date: firstDay,
                breakEntries: aggregatedEntries
            )
        }
        .sorted { $0.date < $1.date }
    }
}

// Helper struct to identify data points for charting
struct ExerciseBreakDataPoint: Identifiable {
    var id: String { "\(date.timeIntervalSince1970)-\(breakType)" }
    var date: Date
    var breakType: String
    var breakValue: Double
}

// Make BreakEntry conform to Identifiable, Hashable for use in ForEach
extension BreakEntry: Identifiable, Hashable {
    var id: String { breakType }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(breakType)
        hasher.combine(breakValue)
    }
    
    static func == (lhs: BreakEntry, rhs: BreakEntry) -> Bool {
        return lhs.breakType == rhs.breakType && lhs.breakValue == rhs.breakValue
    }
}

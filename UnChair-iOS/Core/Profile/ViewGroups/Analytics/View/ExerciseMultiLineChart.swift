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
    
    private var allBreakTypes: [String] {
        var types = Set<String>()
        for model in exerciseData {
            for entry in model.breakEntries {
                types.insert(entry.breakType)
            }
        }
        
        if types.isEmpty {
            types = ["Short", "Quick", "Medium", "Long"]
        }
        
        return Array(types).sorted()
    }
    
    private var organizedDataPoints: [String: [ExerciseBreakDataPoint]] {
        var organized: [String: [ExerciseBreakDataPoint]] = [:]
        
        for breakType in allBreakTypes {
            organized[breakType] = []
        }
        
        for model in exerciseChartData {
            let date = model.date
            let existingBreakTypes = model.breakEntries.map { $0.breakType }
            
            for entry in model.breakEntries {
                let point = ExerciseBreakDataPoint(
                    date: date,
                    breakType: entry.breakType,
                    breakValue: entry.breakValue
                )
                organized[entry.breakType, default: []].append(point)
            }
            
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
        
        for breakType in organized.keys {
            organized[breakType] = organized[breakType]?.sorted(by: { $0.date < $1.date }) ?? []
        }
        
        return organized
    }
    
    private func colorForBreakType(_ type: String) -> Color {
        switch type {
        case "Long": return .yellow
        case "Medium": return .indigo
        case "Quick": return .cyan
        case "Short": return .pink
        default: return .pink
        }
    }
    
    var body: some View {
        VStack {
            Chart {
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
                
                if let selectedItem = selectedViewItem {
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected", selectedItem.date, unit: component))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, spacing: -40, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack(spacing: 2) {
                                let columns = [
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)
                                ]
                                
                                LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                                    ForEach(selectedItem.breakEntries.sorted(by: { $0.breakType < $1.breakType }), id: \.breakType) { entry in
                                        HStack(spacing: 4) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(colorForBreakType(entry.breakType))
                                                .frame(width: 12, height: 4)
                                            Text("\(entry.breakValue, specifier: "%.1f") m")
                                                .font(.caption.bold())
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                if currentTab == "Year" {
                                    Text(selectedItem.date, format: .dateTime.month(.wide))
                                        .font(.caption2)
                                } else {
                                    Text(selectedItem.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                        .font(.caption2)
                                }
                            }
                            .frame(minWidth: 150)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.blue.gradient))
                            //                            .offset(y: 40)
                        }
                }
            }
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
            .chartForegroundStyleScale(domain: allBreakTypes, range: allBreakTypes.map { colorForBreakType($0) })
            .chartLegend(.hidden)
            
            VStack(alignment: .leading) { // Changed to VStack for better top-level alignment of grid
                HStack {
                    ForEach(allBreakTypes, id: \.self) { breakType in
                        legendItem(for: breakType)
                        if breakType != allBreakTypes.last {
                            Spacer()
                        }
                    }
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
    
    private func legendItem(for breakType: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForBreakType(breakType))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading) {
                Text(breakType)
                    .font(.caption)
                
                Text("Break")
                    .font(.caption)
            }
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
            
            var aggregatedBreaks: [String: Double] = [:]
            var breakTypeCounts: [String: Int] = [:]
            
            var allMonthBreakTypes = Set<String>()
            
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
            
            var aggregatedEntries: [BreakEntry] = []
            for (breakType, totalValue) in aggregatedBreaks {
                let count = breakTypeCounts[breakType] ?? 1
                let averageValue = totalValue / Double(count)
                aggregatedEntries.append(BreakEntry(breakType: breakType, breakValue: averageValue))
            }
            
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

struct ExerciseBreakDataPoint: Identifiable {
    var id: String { "\(date.timeIntervalSince1970)-\(breakType)" }
    var date: Date
    var breakType: String
    var breakValue: Double
}

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

//
//  BreakMultiLineChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 8/4/25.
//
import SwiftUI
import Charts

//struct ExerciseMultiLineChart : View {
//    @State private var rawSelectedDate: Date?
//    @Binding var currentActiveItem: ExerciseChartModel?
//    @Binding var plotWidth: CGFloat
//    var exerciseData: [ExerciseChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    @State private var monthlyAggregatedExerciseData: [ExerciseChartModel] = []
//
//    
//    var selectedViewItem: ExerciseChartModel? {
//        guard let rawSelectedDate else { return nil }
//        
//        // Different granularity based on the tab
//        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
//        
//        return exerciseChartData.first {
//            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
//        }
//    }
//    
//    private var exerciseChartData: [ExerciseChartModel] {
//        switch currentTab {
//        case "Week":
//            return exerciseData.suffix(7)
//        case "Month":
//            return exerciseData.suffix(30)
//        case "Year":
//            return monthlyAggregatedExerciseData
//        default:
//            return exerciseData
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            Chart {
//                if let selectedItem = selectedViewItem {
//                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
//                    RuleMark(x: .value("Selected", selectedItem.date, unit: component))
//                        .foregroundStyle(.secondary.opacity(0.3))
//                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
//                            VStack{
//                                if currentTab == "Year" {
//                                    Text(selectedItem.date, format: .dateTime.month(.wide))
//                                        .bold()
//                                } else {
//                                    Text(selectedItem.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
//                                        .bold()
//                                }
//                                
//                                Text("\(selectedItem.consumption, specifier: "%.1f")")
//                                    .font(.title3.bold())
//                            }
//                            .foregroundStyle(.white)
//                            .padding(12)
//                            .frame(width: 120)
//                            .background(RoundedRectangle(cornerRadius: 10).fill(.pink.gradient))
//                        }
//                }
//                
//                RuleMark(y: .value("Goal", 3000))
//                    .foregroundStyle(Color.mint)
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
//                    .annotation(alignment: .leading){
//                        Text("Goal")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                
//                ForEach(exerciseChartData) { data in
//                    data.forEach { exercise in
//                        LineMark(
//                            x: .value("Date", data.date, unit: currentTab == "Year" ? .month : .day),
//                            y: .value("Value", exercise.breakValue)
//                        )
//                    }
//                    .cornerRadius(4)
//                    .foregroundStyle(Color.pink.gradient)
//                    .opacity(rawSelectedDate == nil || Calendar.current.isDate(water.date,
//                             equalTo: selectedViewItem?.date ?? Date(),
//                             toGranularity: currentTab == "Year" ? .month : .day) ? 1.0 : 0.3)
//                }
//            }
//            .frame(height: 180)
//            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
//            .onChange(of: waterData) { oldData, newData in
//                if currentTab == "Year" {
//                    monthlyAggregatedWaterData = aggregateByMonth(newData).suffix(12)
//                }
//            }
//            .chartXAxis {
//                if currentTab == "Year" {
//                    AxisMarks(values: .stride(by: .month)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(date, format: .dateTime.month(.narrow))
//                            }
//                            AxisTick()
//                            AxisGridLine()
//                        }
//                    }
//                } else if currentTab == "Week" {
//                    AxisMarks(values: .stride(by: .day)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(date, format: .dateTime.weekday(.abbreviated))
//                            }
//                            AxisTick()
//                            AxisGridLine()
//                        }
//                    }
//                } else if currentTab == "Month" {
//                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(date, format: .dateTime.day())
//                            }
//                            AxisTick()
//                            AxisGridLine()
//                        }
//                    }
//                }
//            }
//            .chartYAxis{
//                AxisMarks { value in
//                    AxisValueLabel()
//                    AxisGridLine()
//                }
//            }
//        }
//        .padding()
//    }
//    
//    private func aggregateByMonth(_ data: [WaterChartModel]) -> [WaterChartModel] {
//        let calendar = Calendar.current
//        
//        let groupedData = Dictionary(grouping: data) { item in
//            let components = calendar.dateComponents([.year, .month], from: item.date)
//            return components
//        }
//        
//        return groupedData.map { (components, items) in
//            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
//            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
//            
//            let nonZeroItems = items.filter { $0.consumption > 0 }
//            let totalConsumption = nonZeroItems.reduce(0) { $0 + $1.consumption }
//            let averageConsumption = nonZeroItems.isEmpty ? 0 : totalConsumption / Double(nonZeroItems.count)
//            
//            return WaterChartModel(
//                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
//                date: firstDay,
//                consumption: averageConsumption
//            )
//        }
//        .sorted { $0.date < $1.date }
//    }
//}




struct ExerciseMultiLineChart: View {
    @State private var rawSelectedDate: Date?
    @Binding var currentActiveItem: ExerciseChartModel?
    @Binding var plotWidth: CGFloat
    var exerciseData: [ExerciseChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var monthlyAggregatedExerciseData: [ExerciseChartModel] = []
    
    /// For the annotation, pick a selected exercise chart model based on the rawSelectedDate.
    var selectedViewItem: ExerciseChartModel? {
        guard let rawSelectedDate else { return nil }
        
        // Use .month granularity for Year, otherwise .day.
        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
        
        return exerciseChartData.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
        }
    }
    
    /// Data used for the chart – either the full exerciseData or aggregated monthly.
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
    
    /// Flatten the exercise data so that each break entry becomes its own data point.
    private var flattenedExerciseData: [ExerciseBreakDataPoint] {
        exerciseChartData.flatMap { model in
            model.breakEntries.map { entry in
                ExerciseBreakDataPoint(date: model.date,
                                       breakType: entry.breakType,
                                       breakValue: entry.breakValue)
            }
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                // Annotation for the selected date.
                if let selectedItem = selectedViewItem {
                    let unit: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected", selectedItem.date, unit: unit))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack {
                                if currentTab == "Year" {
                                    Text(selectedItem.date, format: .dateTime.month(.wide))
                                        .bold()
                                } else {
                                    Text(selectedItem.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                        .bold()
                                }
                                // Display the total break time for that day or month.
                                Text("\(selectedItem.totalBreakTime, specifier: "%.1f")")
                                    .font(.title3.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.pink.gradient))
                        }
                }
                
                // Optional goal line.
                RuleMark(y: .value("Goal", 3000))
                    .foregroundStyle(Color.mint)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                
                // Plot the data – one line per break type.
                ForEach(Set(flattenedExerciseData.map { $0.breakType }), id: \.self) { breakType in
                    // Filter data points for this break type.
                    let series = flattenedExerciseData.filter { $0.breakType == breakType }
                    
                    // Plot a line connecting all data points for this break type.
                    ForEach(series) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date, unit: currentTab == "Year" ? .month : .day),
                            y: .value("Value", dataPoint.breakValue)
                        )
                        .foregroundStyle(by: .value("Break Type", dataPoint.breakType))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    
                    // Also plot a dot at each data point.
                    ForEach(series) { dataPoint in
                        PointMark(
                            x: .value("Date", dataPoint.date, unit: currentTab == "Year" ? .month : .day),
                            y: .value("Value", dataPoint.breakValue)
                        )
                        .foregroundStyle(by: .value("Break Type", dataPoint.breakType))
                        .symbol(Circle())
                    }
                }
            }
            .frame(height: 180)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: exerciseData) { oldData, newData in
                if currentTab == "Year" {
                    monthlyAggregatedExerciseData = aggregateByMonth(newData).suffix(12)
                }
            }
            .chartXAxis {
                if currentTab == "Year" {
                    AxisMarks(values: .stride(by: .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.narrow))
                            }
                            AxisTick()
                            AxisGridLine()
                        }
                    }
                } else if currentTab == "Week" {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
                            AxisTick()
                            AxisGridLine()
                        }
                    }
                } else if currentTab == "Month" {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.day())
                            }
                            AxisTick()
                            AxisGridLine()
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
        .padding()
    }
    
    // MARK: - Aggregation Helper
    
    /// Aggregate the exercise data by month.
    /// For each month, for each break type, we average non-zero values.
    private func aggregateByMonth(_ data: [ExerciseChartModel]) -> [ExerciseChartModel] {
        let calendar = Calendar.current
        let groupedData = Dictionary(grouping: data) { model in
            calendar.dateComponents([.year, .month], from: model.date)
        }
        
        return groupedData.map { (components, models) in
            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
            
            // Aggregate break entries for each break type.
            var aggregatedEntries: [BreakEntry] = []
            let breakTypes = Set(models.flatMap { $0.breakEntries.map { $0.breakType } })
            for type in breakTypes {
                let values = models.compactMap { model in
                    model.breakEntries.first(where: { $0.breakType == type })?.breakValue
                }
                let nonZeroValues = values.filter { $0 > 0 }
                let average = nonZeroValues.isEmpty ? 0 : nonZeroValues.reduce(0, +) / Double(nonZeroValues.count)
                aggregatedEntries.append(BreakEntry(breakType: type, breakValue: average))
            }
            
            return ExerciseChartModel(date: firstDay, breakEntries: aggregatedEntries)
        }
        .sorted { $0.date < $1.date }
    }
}

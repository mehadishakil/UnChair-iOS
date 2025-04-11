//
//  BarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//
//
//import SwiftUI
//import Charts
//
//struct StepsLineChart: View {
//    @Binding var currentActiveItem: StepsChartModel?
//    @Binding var plotWidth: CGFloat
//    var stepsData: [StepsChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        let maxSteps = stepsData.max { $0.steps < $1.steps }?.steps ?? 0
//        
//        buildChart(maxSteps: Double(maxSteps))
//            .chartOverlay(content: chartOverlay)
//            .frame(height: 200)
//        
//    }
//    
//    private func buildChart(maxSteps: Double) -> some View {
//        Chart(stepsData) {
//            BarMark(
//                x: .value("Date", $0.date),
//                y: .value("Steps", $0.steps)
//            )
//            .foregroundStyle(Color.blue)
//
//            
//            if let currentActiveItem, currentActiveItem.id == $0.id {
//                RuleMark(x: .value("Date", currentActiveItem.date))
//                    .foregroundStyle(Color.gray.opacity(0.3))
//                    .lineStyle(.init(lineWidth: 2))
//                    .annotation(position: .top, spacing: 0) {
//                        annotationView(for: currentActiveItem)
//                    }
//            }
//        }
//        .chartXAxis {
//            switch currentTab {
//            case "Week":
//                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            Text(formatDate(date, format: "E"))
//                                .font(.caption2)
//                        }
//                    }
//                }
//            case "Month":
//                AxisMarks(preset: .aligned, values: stepsData.map { $0.date }) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            Text(formatDate(date, format: "dd MMM"))
//                                .font(.caption2)
//                        }
//                    }
//                }
//            case "Year":
//                AxisMarks(preset: .aligned, values: .stride(by: .month, count: 2)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            Text(formatDate(date, format: "MMM"))
//                                .font(.caption2)
//                        }
//                    }
//                }
//            default:
//                AxisMarks(preset: .aligned, values: .stride(by: .month, count: 3)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            Text(formatDate(date, format: "MMM yy"))
//                                .font(.caption2)
//                        }
//                    }
//                }
//            }
//        }
//        .chartYAxis {
//            AxisMarks(position: .trailing, values: .automatic) {
//                AxisTick()
//                AxisValueLabel(horizontalSpacing: 20)
//            }
//        }
//        //.chartYScale(domain: 0...(maxSteps + 500))
//    }
//    
//    
//    private func formatDate(_ date: Date, format: String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
//        return formatter.string(from: date)
//    }
//    
//    
//    private func chartOverlay(content: ChartProxy) -> some View {
//        GeometryReader { innerProxy in
//            Rectangle().fill(.clear).contentShape(Rectangle())
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { value in handleDragChange(value, in: content) }
//                        .onEnded { _ in currentActiveItem = nil }
//                )
//        }
//    }
//    
//    private func handleDragChange(_ value: DragGesture.Value, in content: ChartProxy) {
//        let location = value.location
//        if let date: Date = content.value(atX: location.x),
//           let currentItem = stepsData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
//            currentActiveItem = currentItem
//            plotWidth = content.plotSize.width
//        }
//    }
//    
//    private func annotationView(for item: StepsChartModel) -> some View {
//        VStack(alignment: .center, spacing: 2) {
//            Text("Steps")
//                .font(.caption2)
//                .foregroundColor(.secondary)
//            Text("\(item.steps)")
//                .font(.caption)
//                .fontWeight(.heavy)
//                .foregroundColor(Color(red: 44/255, green: 102/255, blue: 246/255))
//        }
//        .padding(.horizontal, 6)
//        .padding(.vertical, 2)
//        .background(
//            RoundedRectangle(cornerRadius: 4)
//            .fill(colorScheme == .dark ? Color.darkGray.shadow(.drop(radius: 1)) : Color.gray3.shadow(.drop(radius: 1)))
//        )
//    }
//}



import SwiftUI
import Charts

struct StepsLineChart: View {
    @State private var rawSelectedDate: Date?
    @Binding var currentActiveItem: StepsChartModel?
    @Binding var plotWidth: CGFloat
    var stepsData: [StepsChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var monthlyAggregatedStepsData: [StepsChartModel] = []

    
    var selectedViewItem: StepsChartModel? {
        guard let rawSelectedDate else { return nil }
        
        // Different granularity based on the tab
        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
        
        return stepsChartData.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
        }
    }
    
    private var stepsChartData: [StepsChartModel] {
        switch currentTab {
        case "Week":
            return stepsData.suffix(7)
        case "Month":
            return stepsData.suffix(30)
        case "Year":
            return monthlyAggregatedStepsData
        default:
            return stepsData
        }
    }

    
    var body: some View {
        VStack {
            Chart {
                // Add rule mark for goal
                RuleMark(y: .value("Goal", 3000))
                    .foregroundStyle(Color.mint)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading){
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                
                // Add data points with optimized rendering
                ForEach(stepsChartData) { data in
                    let isHighlighted = rawSelectedDate == nil ||
                                      (selectedViewItem != nil &&
                                       Calendar.current.isDate(data.date,
                                       equalTo: selectedViewItem!.date,
                                       toGranularity: currentTab == "Year" ? .month : .day))
                    
                    LineMark(
                        x: .value("Day", data.date, unit: currentTab == "Year" ? .month : .day),
                        y: .value("Steps", data.steps)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .opacity(isHighlighted ? 1.0 : 0.3)

                    PointMark(
                        x: .value("Day", data.date, unit: currentTab == "Year" ? .month : .day),
                        y: .value("Steps", data.steps)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .symbolSize(currentTab == "Month" || currentTab == "Year" ? 60 : 80)
                    .opacity(isHighlighted ? 1.0 : 0.3)
                }
                
                // Add selection annotation last (on top)
                if let selectedItem = selectedViewItem {
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected", selectedItem.date, unit: component))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack{
                                if currentTab == "Year" {
                                    Text(selectedItem.date, format: .dateTime.month(.wide))
                                        .bold()
                                } else {
                                    Text(selectedItem.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                        .bold()
                                }
                                
                                Text("\(selectedItem.steps)")
                                    .font(.title3.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.blue.gradient))
                        }
                }
            }
            .frame(height: 180)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: stepsData) { oldData, newData in
                if currentTab == "Year" {
                    monthlyAggregatedStepsData = aggregateByMonth(newData).suffix(12)
                }
            }
            .chartXAxis {
                if currentTab == "Year" {
                    AxisMarks(values: .stride(by: .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.narrow))
                            }
//                            AxisTick()
//                            AxisGridLine()
                        }
                    }
                } else if currentTab == "Week" {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
//                            AxisTick()
//                            AxisGridLine()
                        }
                    }
                } else if currentTab == "Month" {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.day())
                            }
//                            AxisTick()
//                            AxisGridLine()
                        }
                    }
                }
            }
            .chartYAxis{
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
        }
        .padding()
        .onAppear {
            print("StepsLineChart appeared with \(stepsData.count) data points")
            print("Year tab has \(aggregateByMonth(stepsData).suffix(12).count) data points")
        }
    }
    
    private func aggregateByMonth(_ data: [StepsChartModel]) -> [StepsChartModel] {
        // Make sure we have data to process
        if data.isEmpty {
            print("Warning: No data to aggregate by month")
            return []
        }
        
        let calendar = Calendar.current
        
        // Create dictionary grouping by month
        var monthToItemsMap: [String: [StepsChartModel]] = [:]
        
        for item in data {
            let year = calendar.component(.year, from: item.date)
            let month = calendar.component(.month, from: item.date)
            let key = "\(year)-\(month)"
            
            if monthToItemsMap[key] == nil {
                monthToItemsMap[key] = []
            }
            monthToItemsMap[key]?.append(item)
        }
        
        // Process each month's data
        let result = monthToItemsMap.compactMap { (key, items) -> StepsChartModel? in
            guard let firstDate = items.first?.date else { return nil }
            
            // Create first day of month date
            let components = calendar.dateComponents([.year, .month], from: firstDate)
            guard let monthDate = calendar.date(from: components) else { return nil }
            
            let nonZeroItems = items.filter { $0.steps > 0 }
            let totalSteps = nonZeroItems.reduce(0) { $0 + $1.steps }
            let averageSteps = nonZeroItems.isEmpty ? 0 : totalSteps / nonZeroItems.count
            
            return StepsChartModel(
                id: "month-\(key)",
                date: monthDate,
                steps: averageSteps
            )
        }
        
        // Sort by date and return
        return result.sorted { $0.date < $1.date }
    }
}

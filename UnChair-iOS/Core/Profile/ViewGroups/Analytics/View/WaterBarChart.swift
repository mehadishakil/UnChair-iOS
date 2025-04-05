//
//  LineChartView.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 10/9/24.
//
//
import SwiftUI
import Charts

struct WaterBarChart: View {
    @Binding var currentActiveItem: WaterChartModel?
    @Binding var plotWidth: CGFloat
    var waterData: [WaterChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    
    private var barWidth: MarkDimension {
        switch currentTab {
        case "Week":
            return MarkDimension(floatLiteral: 24)
        case "Month":
            return MarkDimension(floatLiteral: 8)
        case "Year":
            return MarkDimension(floatLiteral: 15)
        default:
            return MarkDimension(floatLiteral: 15)
        }
    }
    
    private var waterChartData: [WaterChartModel] {
        switch currentTab {
        case "Week":
            return waterData.suffix(7) // Last 7 days
        case "Month":
            return waterData.suffix(30) // Last 30 days
        case "Year":
            return aggregateByMonth(waterData).suffix(12) // Last 12 months
        default:
            return waterData
        }
    }

    var body: some View {
        let maxConsumption = waterData.max { $0.consumption < $1.consumption }?.consumption ?? 0

        VStack(spacing: 0) {
            Chart {
                ForEach(waterChartData) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Consumption", item.consumption),
                        width: barWidth
                    )
                    .foregroundStyle(Color.blue)
                }
                
                if let currentActiveItem {
                    RuleMark(
                        x: .value("Date", currentActiveItem.date)
                    )
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .annotation(position: .top) {
                        VStack(alignment: .center, spacing: 4) {
                            Text(formatDate(currentActiveItem.date, tab: currentTab))
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text("\(Int(currentActiveItem.consumption)) ml")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.2))
                        )
                    }
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: getDesiredAxisCount())) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatAxisLabel(date))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleDragChange(value, in: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    currentActiveItem = nil
                                }
                        )
                }
            }
        }
    }
    
    private func getDesiredAxisCount() -> Int {
        switch currentTab {
        case "Week": return 7
        case "Month": return 10
        case "Year": return 12
        default: return 7
        }
    }
    
    private func formatAxisLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch currentTab {
        case "Week":
            formatter.dateFormat = "E"
        case "Month":
            formatter.dateFormat = "dd"
        case "Year":
            formatter.dateFormat = "MMM"
            let monthString = formatter.string(from: date)
            return String(monthString.prefix(1))
        default:
            formatter.dateFormat = "MMM"
        }
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date, tab: String) -> String {
        let formatter = DateFormatter()
        switch tab {
        case "Year":
            formatter.dateFormat = "MMM yyyy"
        default:
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: date)
    }
    
    private func aggregateByMonth(_ data: [WaterChartModel]) -> [WaterChartModel] {
        let calendar = Calendar.current
        
        let groupedData = Dictionary(grouping: data) { item in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return components
        }
        
        return groupedData.map { (components, items) in
            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
            
            let nonZeroItems = items.filter { $0.consumption > 0 }
            let totalConsumption = nonZeroItems.reduce(0) { $0 + $1.consumption }
            let averageConsumption = nonZeroItems.isEmpty ? 0 : totalConsumption / Double(nonZeroItems.count)
            
            return WaterChartModel(
                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
                date: firstDay,
                consumption: averageConsumption
            )
        }
        .sorted { $0.date < $1.date }
    }

    private func handleDragChange(_ value: DragGesture.Value, in proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = value.location.x
        
        if let date = proxy.value(atX: xPosition) as Date? {
            // Find the closest item in waterChartData, not waterData
            if let item = waterChartData.min(by: {
                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
            }) {
                currentActiveItem = item
                plotWidth = geometry.size.width
            }
        }
    }
}














//import SwiftUI
//import Charts
//
//struct WaterBarChart: View {
//    @Binding var currentActiveItem: WaterChartModel?
//    @Binding var plotWidth: CGFloat
//    var waterData: [WaterChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    
//    
//    private var barWidth: MarkDimension {
//        switch currentTab {
//        case "Week":
//            return MarkDimension(floatLiteral: 24)
//        case "Month":
//            return MarkDimension(floatLiteral: 8)
//        case "Year":
//            return MarkDimension(floatLiteral: 15)
//        default:
//            return MarkDimension(floatLiteral: 15)
//        }
//    }
//    
//    private var waterChartData: [WaterChartModel] {
//        switch currentTab {
//        case "Week":
//            return waterData.suffix(7) // Last 7 days
//        case "Month":
//            return waterData.suffix(30) // Last 30 days
//        case "Year":
//            return aggregateByMonth(waterData).suffix(12) // Last 12 months
//        default:
//            return waterData
//        }
//    }
//
//    var body: some View {
//        let maxConsumption = waterData.max { $0.consumption < $1.consumption }?.consumption ?? 0
//
//        VStack(spacing: 0) {
//            Chart {
//                ForEach(waterChartData) { item in
//                    BarMark(
//                        x: .value("Date", item.date),
//                        y: .value("Consumption", item.consumption),
//                        width: barWidth
//                    )
//                    .foregroundStyle(Color.blue)
////                    .opacity(currentActiveItem?.id == item.id || currentActiveItem == nil ? 1.0 : 0.3)
//                }
//                
//                if let currentActiveItem {
//                    RuleMark(
//                        x: .value("Date", currentActiveItem.date)
//                    )
//                    .foregroundStyle(Color.gray.opacity(0.3))
//                    .annotation(position: .top) {
//                        VStack(alignment: .center, spacing: 4) {
//                            Text(formatDate(currentActiveItem.date, format: currentTab == "Year" ? "MMM yyyy" : "MMM d"))
//                                .font(.caption)
//                                .fontWeight(.bold)
//                            
//                            Text("\(Int(currentActiveItem.consumption)) ml")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                        }
//                        .padding(8)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(Color.blue.opacity(0.2))
//                        )
//                    }
//                }
//            }
//            .frame(height: 180)
//            // .chartXScale(domain: chartDateRange()) // Set fixed date range to ensure all data fits
//            .chartXAxis {
//                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel {
//                            Text(formatDate(waterChartData.date, index: waterChartData.firstIndex(of: waterChartData) ?? 0))
//                                .font(.caption2)
//                        }
//                    }
//                }
////                switch currentTab {
////                case "Week":
////                    
////                case "Month":
////                    AxisMarks(preset: .aligned, values: .stride(by: .day, count: 7)) { value in
////                        if let date = value.as(Date.self) {
////                            AxisValueLabel {
////                                Text(formatDate(date, format: "d"))
////                                    .font(.caption2)
////                            }
////                        }
////                    }
////                case "Year":
////                    AxisMarks(preset: .aligned, values: .stride(by: .month)) { value in
////                        if let date = value.as(Date.self) {
////                            AxisValueLabel {
////                                Text(formatDate(date, format: "MMM"))
////                                    .font(.caption2)
////                            }
////                        }
////                    }
////                default:
////                    AxisMarks(preset: .aligned, values: .stride(by: .month, count: 3)) { value in
////                        if let date = value.as(Date.self) {
////                            AxisValueLabel {
////                                Text(formatDate(date, format: "MMM"))
////                                    .font(.caption2)
////                            }
////                        }
////                    }
////                }
//            }
//            .chartYAxis {
//                AxisMarks {
//                    AxisTick()
//                    AxisValueLabel()
//                }
//            }
//            .chartOverlay { proxy in
//                GeometryReader { geometry in
//                    Rectangle()
//                        .fill(Color.clear)
//                        .contentShape(Rectangle())
//                        .gesture(
//                            DragGesture(minimumDistance: 0)
//                                .onChanged { value in
//                                    handleDragChange(value, in: proxy, geometry: geometry)
//                                }
//                                .onEnded { _ in
//                                    currentActiveItem = nil
//                                }
//                        )
//                }
//            }
//        }
//    }
//    
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
//
//    private func handleDragChange(_ value: DragGesture.Value, in proxy: ChartProxy, geometry: GeometryProxy) {
//        let xPosition = value.location.x
//        let relativeXPosition = xPosition / geometry.size.width
//        
//        // Convert the relative position to a date
//        if let date = proxy.value(atX: xPosition) as Date? {
//            // Find the closest data point
//            if let item = waterData.min(by: {
//                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
//            }) {
//                currentActiveItem = item
//                plotWidth = geometry.size.width
//            }
//        }
//    }
//
////    private func formatDate(_ date: Date, format: String) -> String {
////        let formatter = DateFormatter()
////        formatter.dateFormat = format
////        return formatter.string(from: date)
////    }
//    
//    private func formatDate(_ date: Date, index: Int) -> String {
//        let formatter = DateFormatter()
//        switch currentTab {
//        case "Week":
//            formatter.dateFormat = "E"
//            return formatter.string(from: date)
//        case "Month":
//            formatter.dateFormat = "dd"
//            // Show every 5th day label for month view to avoid crowding
//            return index % 3 == 0 ? formatter.string(from: date) : ""
//        case "Year":
//            formatter.dateFormat = "MMM"
//            let monthString = formatter.string(from: date)
//            return String(monthString.prefix(1))
//        default:
//            formatter.dateFormat = "MMM yy"
//            return formatter.string(from: date)
//        }
//    }
//}
















//AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
//extension Date{
//    static func from(year: Int, month: Int, day: Int) -> Date? {
//        let components = DateComponents(year: year, month: month, day: day)
//        return Calendar.current.date(from: components)
//    }
//}


//
//import SwiftUI
//import Charts
//
//struct WaterBarChart: View {
//    @Binding var currentActiveItem: WaterChartModel?
//    @Binding var plotWidth: CGFloat
//    var waterData: [WaterChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    
//    private var displayData: [WaterChartModel] {
//        switch currentTab {
//        case "Week", "Month":
//            return waterData  // Ensure that waterData already contains the full set for the period
//        case "Year":
//            // Group by month and calculate monthly averages
//            let calendar = Calendar.current
//            let groupedByMonth = Dictionary(grouping: waterData) { item in
//                let components = calendar.dateComponents([.year, .month], from: item.date)
//                return calendar.date(from: components)!
//            }
//            return groupedByMonth.map { date, items in
//                let totalConsumption = items.reduce(0) { $0 + $1.consumption }
//                let averageConsumption = totalConsumption / Double(items.count)
//                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption)
//            }
//            .sorted { $0.date < $1.date }
//        default:
//            return waterData
//        }
//    }
//
//    
//    // Dynamic bar width based on current tab
//    private var barWidth: MarkDimension {
//        switch currentTab {
//        case "Week":
//            return MarkDimension(floatLiteral: 24)
//        case "Month":
//            return MarkDimension(floatLiteral: 8)
//        case "Year":
//            return MarkDimension(floatLiteral: 20)
//        default:
//            return MarkDimension(floatLiteral: 15)
//        }
//    }
//
//
//    var body: some View {
////        let maxConsumption = displayData.max { $0.consumption < $1.consumption }?.consumption ?? 0
//
//        VStack {
//            Chart {
//                ForEach(displayData) { item in
//                    BarMark(
//                        x: .value("Date", item.date),
//                        y: .value("Consumption", item.consumption),
//                        width: barWidth // Using dynamic bar width
//                    )
//                    .foregroundStyle(Color.blue.gradient)
//                    .opacity(currentActiveItem?.id == item.id || currentActiveItem == nil ? 1.0 : 0.3)
//                }
//                
//                if let currentActiveItem {
//                    RuleMark(
//                        x: .value("Date", currentActiveItem.date)
//                    )
//                    .foregroundStyle(Color.gray.opacity(0.3))
//                    .annotation(position: .top) {
//                        VStack(alignment: .center, spacing: 4) {
//                            Text(formatDate(currentActiveItem.date, format: currentTab == "Year" ? "MMM yyyy" : "MMM d"))
//                                .font(.caption)
//                                .fontWeight(.bold)
//                            
//                            Text("\(Int(currentActiveItem.consumption)) ml")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                        }
//                        .padding(8)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(Color.blue.opacity(0.2))
//                        )
//                    }
//                }
//            }
//            .frame(height: 180)
//            .chartXScale(domain: chartDateRange()) // Set fixed date range to ensure all data fits
//            .chartXAxis {
//                switch currentTab {
//                case "Week":
//                    AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(formatDate(date, format: "E"))
//                                    .font(.caption2)
//                            }
//                        }
//                    }
//                case "Month":
//                    AxisMarks(preset: .aligned, values: .stride(by: .day, count: 5)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(formatDate(date, format: "d"))
//                                    .font(.caption2)
//                            }
//                        }
//                    }
//                case "Year":
//                    AxisMarks(preset: .aligned, values: .stride(by: .month)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(formatDate(date, format: "MMM"))
//                                    .font(.caption2)
//                            }
//                        }
//                    }
//                default:
//                    AxisMarks(preset: .aligned, values: .stride(by: .month, count: 3)) { value in
//                        if let date = value.as(Date.self) {
//                            AxisValueLabel {
//                                Text(formatDate(date, format: "MMM"))
//                                    .font(.caption2)
//                            }
//                        }
//                    }
//                }
//            }
//
//            .chartYAxis {
//                AxisMarks {
//                    AxisTick()
//                    AxisValueLabel()
//                }
//            }
//            .chartOverlay { proxy in
//                GeometryReader { geometry in
//                    Rectangle()
//                        .fill(Color.clear)
//                        .contentShape(Rectangle())
//                        .gesture(
//                            DragGesture(minimumDistance: 0)
//                                .onChanged { value in
//                                    handleDragChange(value, in: proxy, geometry: geometry)
//                                }
//                                .onEnded { _ in
//                                    currentActiveItem = nil
//                                }
//                        )
//                }
//            }
//        }
//    }
//    
//    private func chartDateRange() -> ClosedRange<Date> {
//        let calendar = Calendar.current
//        guard let minDate = displayData.min(by: { $0.date < $1.date })?.date,
//              let maxDate = displayData.max(by: { $0.date < $1.date })?.date else {
//            return Date().addingTimeInterval(-86400 * 7)...Date()
//        }
//        
//        switch currentTab {
//        case "Week":
//            let startOfWeek = calendar.date(byAdding: .day, value: -1, to: minDate) ?? minDate
//            let endOfWeek = calendar.date(byAdding: .day, value: 1, to: maxDate) ?? maxDate
//            return startOfWeek...endOfWeek
//        case "Month":
//            let startOfMonth = calendar.date(byAdding: .day, value: -1, to: minDate) ?? minDate
//            let endOfMonth = calendar.date(byAdding: .day, value: 1, to: maxDate) ?? maxDate
//            return startOfMonth...endOfMonth
//        case "Year":
//            let startOfYear = calendar.date(byAdding: .day, value: -15, to: minDate) ?? minDate
//            let endOfYear = calendar.date(byAdding: .day, value: 15, to: maxDate) ?? maxDate
//            return startOfYear...endOfYear
//        default:
//            let start = calendar.date(byAdding: .day, value: -1, to: minDate) ?? minDate
//            let end = calendar.date(byAdding: .day, value: 1, to: maxDate) ?? maxDate
//            return start...end
//        }
//    }
//
//
//    private func handleDragChange(_ value: DragGesture.Value, in proxy: ChartProxy, geometry: GeometryProxy) {
//        let xPosition = value.location.x
//        
//        // Convert the position to a date
//        if let date = proxy.value(atX: xPosition) as Date? {
//            // Find the closest data point
//            if let item = displayData.min(by: {
//                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
//            }) {
//                currentActiveItem = item
//                plotWidth = geometry.size.width
//            }
//        }
//    }
//
//    private func formatDate(_ date: Date, format: String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
//        return formatter.string(from: date)
//    }
//
//}

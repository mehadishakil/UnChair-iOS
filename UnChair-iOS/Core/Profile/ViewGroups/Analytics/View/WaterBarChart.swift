//
//  Sample.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/4/25.
//
// .chartXScale(domain: minDate...maxDate)


//import SwiftUI
//import Charts
//
//struct Sample : View {
//    
//    @State private var rawSelectedDate: Date?
//    var selectedViewMonth: ViewMonth? {
//        guard let rawSelectedDate else { return nil }
//        return viewMonths.first {
//            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: .month)
//        }
//    }
//    
//    let viewMonths: [ViewMonth] = [
//        .init(date: Date.from(year: 2023, month: 1, day: 1), viewCount: 55000),
//        .init(date: Date.from(year: 2023, month: 2, day: 1), viewCount: 89000),
//        .init(date: Date.from(year: 2023, month: 3, day: 1), viewCount: 64000),
//        .init(date: Date.from(year: 2023, month: 4, day: 1), viewCount: 79000),
//        .init(date: Date.from(year: 2023, month: 5, day: 1), viewCount: 13000),
//        .init(date: Date.from(year: 2023, month: 6, day: 1), viewCount: 90000),
//        .init(date: Date.from(year: 2023, month: 7, day: 1), viewCount: 88000),
//        .init(date: Date.from(year: 2023, month: 8, day: 1), viewCount: 64000),
//        .init(date: Date.from(year: 2023, month: 9, day: 1), viewCount: 74000),
//        .init(date: Date.from(year: 2023, month: 10, day: 1), viewCount: 99000),
//        .init(date: Date.from(year: 2023, month: 11, day: 1), viewCount: 110000),
//        .init(date: Date.from(year: 2023, month: 12, day: 1), viewCount: 94000)
//    ]
//
//    var body: some View {
//        VStack {
//            Chart {
//                
//                if let selectedViewMonth {
//                    RuleMark(x: .value("Selected Month", selectedViewMonth.date, unit: .month))
//                        .foregroundStyle(.secondary.opacity(0.3))
//                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
//                            VStack{
//                                Text(selectedViewMonth.date, format: .dateTime.month(.wide))
//                                    .bold()
//                                
//                                Text("\(selectedViewMonth.viewCount)")
//                                    .font(.title3.bold())
//                            }
//                            .foregroundStyle(.white)
//                            .padding(12)
//                            .frame(width: 120)
//                            .background(RoundedRectangle(cornerRadius: 10).fill(.pink.gradient))
//                        }
//                }
//                
//                
//                RuleMark(y: .value("Goal", 80000))
//                    .foregroundStyle(Color.mint)
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
//                    .annotation(alignment: .leading){
//                        Text("Goal")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                ForEach(viewMonths) { viewMonths in
//                    BarMark(x: .value("Month", viewMonths.date, unit: .month), y: .value("Views", viewMonths.viewCount))
//                        .foregroundStyle(Color.pink.gradient)
//                        .opacity(rawSelectedDate == nil || viewMonths.date == selectedViewMonth?.date ? 1.0 : 0.3)
//                }
//            }
//            .frame(height: 180)
//            // .chartXScale(domain: minDate...maxDate)
//            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
//            .onChange(of: selectedViewMonth?.viewCount, { oldValue, newValue in
//                print(newValue)
//            })
//            .chartXAxis{
//                AxisMarks(values: viewMonths.map { $0.date }) {date in
//                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
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
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//            // Create a mock AuthController instance (or use a real one if necessary)
//            let authController = AuthController()
//            
//            // Provide the AuthController to the environment
//            return Sample()
//            .environmentObject(authController)  // Inject the AuthController environment object
//        }
//}





import SwiftUI
import Charts

struct WaterBarChart : View {
    @State private var rawSelectedDate: Date?
    @Binding var currentActiveItem: WaterChartModel?
    @Binding var plotWidth: CGFloat
    var waterData: [WaterChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var monthlyAggregatedWaterData: [WaterChartModel] = []

    
    var selectedViewItem: WaterChartModel? {
        guard let rawSelectedDate else { return nil }
        
        // Different granularity based on the tab
        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
        
        return waterChartData.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
        }
    }
    
    private var waterChartData: [WaterChartModel] {
        switch currentTab {
        case "Week":
            return waterData.suffix(7)
        case "Month":
            return waterData.suffix(30)
        case "Year":
            return monthlyAggregatedWaterData
        default:
            return waterData
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                if let selectedItem = selectedViewItem {
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected", selectedItem.date, unit: component))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack{
                                Text("\(selectedItem.consumption, specifier: "%.1f")")
                                    .font(.caption.bold())
                                
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
                            .background(RoundedRectangle(cornerRadius: 8).fill(.blue.gradient))
                        }
                }
                
                RuleMark(y: .value("Goal", 3000))
                    .foregroundStyle(Color.mint)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading){
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                
                ForEach(waterChartData) { water in
                    BarMark(
                        x: .value("Date", water.date, unit: currentTab == "Year" ? .month : .day),
                        y: .value("Value", water.consumption)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(Color.blue.gradient)
                    .opacity(rawSelectedDate == nil || Calendar.current.isDate(water.date,
                             equalTo: selectedViewItem?.date ?? Date(),
                             toGranularity: currentTab == "Year" ? .month : .day) ? 1.0 : 0.3)
                }
            }
            .frame(height: 160)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: waterData) { oldData, newData in
                if currentTab == "Year" {
                    monthlyAggregatedWaterData = aggregateByMonth(newData).suffix(12)
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
}

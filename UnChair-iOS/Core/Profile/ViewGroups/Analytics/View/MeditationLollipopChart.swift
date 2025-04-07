//
//  MeditationLollipopChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 8/4/25.
//
import SwiftUI
import Charts

struct MeditationLollipopChart: View {
    
    @State private var rawSelectedDate: Date?
    @Binding var currentActiveItem: MeditationChartModel?
    @Binding var plotWidth: CGFloat
    var meditationData: [MeditationChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var monthlyAggregatedMeditationData: [MeditationChartModel] = []

    
    var selectedViewItem: MeditationChartModel? {
        guard let rawSelectedDate else { return nil }
        
        // Different granularity based on the tab
        let granularity: Calendar.Component = currentTab == "Year" ? .month : .day
        
        return meditationChartData.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: granularity)
        }
    }
    
    private var meditationChartData: [MeditationChartModel] {
        switch currentTab {
        case "Week":
            return meditationData.suffix(7)
        case "Month":
            return meditationData.suffix(30)
        case "Year":
            return monthlyAggregatedMeditationData
        default:
            return meditationData
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                if let selectedItem = selectedViewItem {
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    RuleMark(x: .value("Selected Date", selectedItem.date, unit: component))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack {
                                // Use different format based on tab
                                if currentTab == "Year" {
                                    Text(selectedItem.date, format: .dateTime.month(.wide))
                                        .bold()
                                } else {
                                    Text(selectedItem.date, format: .dateTime.day().month(.abbreviated))
                                        .bold()
                                }
                                Text("\(selectedItem.duration, specifier: "%.1f") min")
                                    .font(.title3.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.pink.gradient))
                        }
                }
                
                ForEach(meditationChartData) { data in
                    // Use different calendar unit based on current tab
                    let component: Calendar.Component = currentTab == "Year" ? .month : .day
                    
                    // The point at the top of the vertical line.
                    PointMark(
                        x: .value("Date", data.date, unit: component),
                        y: .value("Duration", data.duration)
                    )
                    .symbol(Circle())
                    .foregroundStyle(Color.pink.gradient)
                    .symbolSize(100)
                    .opacity(rawSelectedDate == nil || data.date == selectedViewItem?.date ? 1.0 : 0.3)
                    
                    // Vertical line (the "stick" of the lollipop).
                    RuleMark(
                        x: .value("Date", data.date, unit: component),
                        yStart: .value("Duration", 0),
                        yEnd: .value("Duration", data.duration)
                    )
                    .foregroundStyle(Color.pink.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .opacity(rawSelectedDate == nil || data.date == selectedViewItem?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 180)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .onChange(of: meditationData) { oldData, newData in
                // Update monthly aggregated data when the meditation data changes
                monthlyAggregatedMeditationData = aggregateByMonth(newData).suffix(12)
            }
            .onAppear {
                // Initialize monthly data when the view appears
                monthlyAggregatedMeditationData = aggregateByMonth(meditationData).suffix(12)
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
            .chartYAxis{
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
        }
        .padding()
    }
    
    
    private func aggregateByMonth(_ data: [MeditationChartModel]) -> [MeditationChartModel] {
        let calendar = Calendar.current
        
        let groupedData = Dictionary(grouping: data) { item in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return components
        }
        
        return groupedData.map { (components, items) in
            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
            
            let nonZeroItems = items.filter { $0.duration > 0 }
            let totalDuration = nonZeroItems.reduce(0) { $0 + $1.duration }
            let averageDuration = nonZeroItems.isEmpty ? 0 : totalDuration / Double(nonZeroItems.count)
            
            return MeditationChartModel(
                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
                date: firstDay,
                duration: averageDuration
            )
        }
        .sorted { $0.date < $1.date }
    }
}

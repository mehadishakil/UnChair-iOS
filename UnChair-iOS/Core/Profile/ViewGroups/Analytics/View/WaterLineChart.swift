//
//  LineChartView.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 10/9/24.
//

import SwiftData
import SwiftUI
import Charts

struct WaterLineChart: View {
    @Binding var currentActiveItem: WaterChartModel?
    @Binding var plotWidth: CGFloat
    var waterData: [WaterChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let maxConsumption = waterData.max { $0.consumption < $1.consumption }?.consumption ?? 0
        
        buildChart(maxConsumption: maxConsumption)
            .chartOverlay(content: chartOverlay)
            .frame(height: 200)
    }
    
    
    private func buildChart(maxConsumption: Double) -> some View {
        Chart(waterData) {
            LineMark(x: .value("Date", $0.date), y: .value("Consumption", $0.consumption))
                .foregroundStyle(Color.blue)
                .interpolationMethod(.catmullRom)
            
            AreaMark(x: .value("Date", $0.date), y: .value("Consumption", $0.consumption))
                //.foregroundStyle(.blue.opacity(0.1).gradient)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)
            
            if let currentActiveItem, currentActiveItem.id == $0.id {
                RuleMark(x: .value("Date", currentActiveItem.date))
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .lineStyle(.init(lineWidth: 2))
                    .annotation(position: .top, spacing: 0) {
                        annotationView(for: currentActiveItem)
                    }
            }
        }
        .chartXAxis {
            switch currentTab {
            case "Week":
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatDate(date, format: "E"))
                                .font(.caption2)
                        }
                    }
                }
            case "Month":
                AxisMarks(preset: .aligned, values: waterData.map { $0.date }) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatDate(date, format: "dd MMM"))
                                .font(.caption2)
                        }
                    }
                }
            case "Year":
                AxisMarks(preset: .aligned, values: .stride(by: .month, count: 2)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatDate(date, format: "MMM"))
                                .font(.caption2)
                        }
                    }
                }
            default:
                AxisMarks(preset: .aligned, values: .stride(by: .month, count: 3)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatDate(date, format: "MMM yy"))
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic) {
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 0...(maxConsumption + 1000))
    }
    
    
    private func strideDates(from endDate: Date, by component: Calendar.Component, value: Int) -> [Date] {
        var dates: [Date] = []
        var currentDate = endDate
        
        for _ in 0..<abs(value) {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: component, value: -1, to: currentDate) ?? endDate
        }
        
        return dates.reversed()
    }
    
    
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch currentTab {
        case "Week":
            formatter.dateFormat = "E" // Display day of the week
        case "Month":
            formatter.dateFormat = "d" // Display day of the month
        case "Year":
            formatter.dateFormat = "MMM" // Display month abbreviation
        default:
            formatter.dateFormat = "MMM yy" // Display month and year
        }
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    
    
    
    private func chartOverlay(content: ChartProxy) -> some View {
        GeometryReader { innerProxy in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in handleDragChange(value, in: content) }
                        .onEnded { _ in currentActiveItem = nil }
                )
        }
    }
    
    private func handleDragChange(_ value: DragGesture.Value, in content: ChartProxy) {
        let location = value.location
        if let date: Date = content.value(atX: location.x),
           let currentItem = waterData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
            currentActiveItem = currentItem
            plotWidth = content.plotSize.width
        }
    }
    
    private func annotationView(for item: WaterChartModel) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Consume")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(item.consumption , specifier: "%.0f") ml")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(Color(red: 44/255, green: 102/255, blue: 246/255))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
            .fill(colorScheme == .dark ? Color.darkGray.shadow(.drop(radius: 1)) : Color.gray3.shadow(.drop(radius: 1)))
        )
    }
}


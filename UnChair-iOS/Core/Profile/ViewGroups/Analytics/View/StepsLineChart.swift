//
//  BarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI
import Charts

struct StepsLineChart: View {
    @Binding var currentActiveItem: StepsChartModel?
    @Binding var plotWidth: CGFloat
    var stepsData: [StepsChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let maxSteps = stepsData.max { $0.steps < $1.steps }?.steps ?? 0
        
        buildChart(maxSteps: Double(maxSteps))
            .chartOverlay(content: chartOverlay)
            .frame(height: 200)
        
    }
    
    private func buildChart(maxSteps: Double) -> some View {
        Chart(stepsData) {
            BarMark(
                x: .value("Date", $0.date),
                y: .value("Steps", $0.steps)
            )
            .foregroundStyle(Color.blue)

            
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
                AxisMarks(preset: .aligned, values: stepsData.map { $0.date }) { value in
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
                AxisValueLabel(horizontalSpacing: 20)
            }
        }
        //.chartYScale(domain: 0...(maxSteps + 500))
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
           let currentItem = stepsData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
            currentActiveItem = currentItem
            plotWidth = content.plotSize.width
        }
    }
    
    private func annotationView(for item: StepsChartModel) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Steps")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(item.steps)")
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

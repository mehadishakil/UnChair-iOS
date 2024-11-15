//
//  ExerciseLineChart.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 16/9/24.
//
import SwiftUI
import SwiftData
import Charts

struct ExerciseBarChart: View {
    @Binding var currentActiveItem: ExerciseChartModel?
    @Binding var plotWidth: CGFloat
    var exerciseData: [ExerciseChartModel]
    @Binding var currentTab: String
    @State private var selectedCount: Int?
    @State private var animationProgress: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Chart {
                ForEach(exerciseData) { model in
                    ForEach(model.breakEntries, id: \.breakType) { entry in
                        BarMark(
                            x: .value("Date", model.date),
                            y: .value("Duration", entry.breakValue)
                        )
                        .foregroundStyle(by: .value("Break Type", entry.breakType))
                    }
                }
                
                if let currentActiveItem {
                    RuleMark(x: .value("Date", currentActiveItem.date))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .lineStyle(.init(lineWidth: 2))
                        .annotation(position: .top, spacing: 0) {
                            annotationView(for: currentActiveItem)
                        }
                }
            }
            .frame(height: 230)
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
                    AxisMarks(preset: .aligned, values: exerciseData.map { $0.date }) { value in
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
            .chartOverlay { proxy in
                chartOverlay(content: proxy)
            }
        }
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
           let currentItem = exerciseData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
            currentActiveItem = currentItem
            plotWidth = content.plotSize.width
        }
    }
    
    private func annotationView(for item: ExerciseChartModel) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Exercise")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            let totalBreakValue = item.breakEntries.reduce(0) { $0 + $1.breakValue }
            
            Text("\(totalBreakValue, specifier: "%.0f") m")
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

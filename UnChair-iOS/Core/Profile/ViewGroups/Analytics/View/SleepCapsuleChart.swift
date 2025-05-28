//
//  CapsuleChart.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//
//

import SwiftUI

struct SleepCapsuleChart: View {
    @State private var currentActiveItem: SleepChartModel?
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    var sleepData: [SleepChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    @State private var dismissTask: DispatchWorkItem?

    // Get the appropriate data based on current tab
    private var displayData: [SleepChartModel] {
        switch currentTab {
        case "Week":
            return sleepData.suffix(7) // Last 7 days
        case "Month":
            return sleepData.suffix(30) // Last 30 days
        case "Year":
            return aggregateByMonth(sleepData).suffix(12) // Last 12 months
        default:
            return sleepData
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.7))
                    .frame(height: 0.5)
                    .frame(maxWidth: .infinity)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                
                HStack(spacing: getSpacing()) {
                    ForEach(displayData) { data in
                        CapsuleItem(
                            data: data,
                            isActive: currentActiveItem?.id == data.id,
                            xAxisLabel: formatDate(data.date, index: displayData.firstIndex(of: data) ?? 0),
                            yAxisValue: (CGFloat(data.sleep) / 60.0 / 12.0) * 100,
                            capsuleWidth: getCapsuleWidth(),
                            currentTab: currentTab
                        )
                        // Use fixed width based on the tab
                        .frame(width: getItemWidth(geo: geo))
                        .frame(height: geo.size.height)
                        .contentShape(Rectangle()) // Ensure the whole area is tappable
                    }
                }
                .padding(.horizontal, 10)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            dragLocation = value.location
                            updateActiveItemBasedOnDrag(geo: geo)
                            
                            // Cancel any pending dismissal when dragging starts or continues
                            dismissTask?.cancel()
                        }
                        .onEnded { _ in
                            isDragging = false
                            
                            // Set up automatic dismissal after dragging ends
                            dismissTask?.cancel()
                            let task = DispatchWorkItem {
                                DispatchQueue.main.async {
                                    if !isDragging {
                                        currentActiveItem = nil
                                    }
                                }
                            }
                            dismissTask = task
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: task)
                        }
                )
            }
        }
        .frame(height: 180)
    }
    
    // Update the active item based on drag position
    private func updateActiveItemBasedOnDrag(geo: GeometryProxy) {
        let availableWidth = geo.size.width - 20 // Account for horizontal padding
        let spacing = getSpacing()
        let itemWidth = getItemWidth(geo: geo)
        let totalItemWidth = itemWidth + spacing
        
        // Calculate the relative position within the chart area
        let relativeX = max(0, min(dragLocation.x - 10, availableWidth))
        
        // Calculate which item index this corresponds to
        let itemIndex = Int(relativeX / totalItemWidth)
        
        // Ensure the index is within bounds
        if itemIndex >= 0 && itemIndex < displayData.count {
            currentActiveItem = displayData[itemIndex]
        }
    }
    
    // Get spacing between capsules based on current tab
    private func getSpacing() -> CGFloat {
        switch currentTab {
        case "Week":
            return 10  // More spacing for week (only 7 items)
        case "Month":
            return 2   // Minimal spacing for month (30 items)
        case "Year":
            return 8   // Medium spacing for year (12 items)
        default:
            return 5
        }
    }
    
    // Get capsule width based on current tab
    private func getCapsuleWidth() -> CGFloat {
        switch currentTab {
        case "Week":
            return 24  // Wider capsules for week
        case "Month":
            return 8   // Narrow capsules for month
        case "Year":
            return 20  // Medium capsules for year
        default:
            return 15
        }
    }
    
    // Calculate the width for each item container based on available space
    private func getItemWidth(geo: GeometryProxy) -> CGFloat {
        let availableWidth = geo.size.width - 20 // Account for horizontal padding
        let count = CGFloat(displayData.count)
        let spacing = getSpacing()
        
        switch currentTab {
        case "Week":
            // For week view, distribute evenly with proper spacing
            return (availableWidth - (spacing * 6)) / 7  // 6 spaces between 7 items
        case "Month":
            // For month view, make sure all 30 days fit
            return (availableWidth - (spacing * 29)) / 30  // 29 spaces between 30 items
        case "Year":
            // For year view, distribute evenly with proper spacing
            return (availableWidth - (spacing * 11)) / 12  // 11 spaces between 12 items
        default:
            return availableWidth / count
        }
    }
    
    private func aggregateByMonth(_ data: [SleepChartModel]) -> [SleepChartModel] {
        let calendar = Calendar.current
        
        let groupedData = Dictionary(grouping: data) { item in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return components
        }
        
        return groupedData.map { (components, items) in
            let firstDayComponents = DateComponents(year: components.year, month: components.month, day: 1)
            let firstDay = calendar.date(from: firstDayComponents) ?? Date()
            
            let nonZeroItems = items.filter { $0.sleep > 0 }
            let totalSleep = nonZeroItems.reduce(0) { $0 + $1.sleep }
            let averageSleep = nonZeroItems.isEmpty ? 0 : totalSleep / Double(nonZeroItems.count)
            
            return SleepChartModel(
                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
                date: firstDay,
                sleep: averageSleep
            )
        }
        .sorted { $0.date < $1.date }
    }
    
    private func formatDate(_ date: Date, index: Int) -> String {
        let formatter = DateFormatter()
        switch currentTab {
        case "Week":
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        case "Month":
            formatter.dateFormat = "dd"
            // Show every 5th day label for month view to avoid crowding
            return index % 3 == 0 ? formatter.string(from: date) : ""
        case "Year":
            formatter.dateFormat = "MMM"
            let monthString = formatter.string(from: date)
            return String(monthString.prefix(1))
        default:
            formatter.dateFormat = "MMM yy"
            return formatter.string(from: date)
        }
    }
}

struct CapsuleItem: View {
    var data: SleepChartModel
    var isActive: Bool
    var xAxisLabel: String
    var yAxisValue: CGFloat
    var capsuleWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme
    var currentTab: String

    var body: some View {
        ZStack {
            VStack {
                // caption
                if isActive {
                    VStack(spacing: 0) {
                        VStack{
                            Text("\(Double(data.sleep) / 60.0, specifier: "%.1f")h")
                                .font(.caption.bold())
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .transition(.opacity.combined(with: .scale))
                            
                            if currentTab == "Year" {
                                Text(data.date, format: .dateTime.month(.wide))
                                    .font(.caption2)
                            } else {
                                Text(data.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.blue.gradient))
                        .frame(minWidth: max(capsuleWidth * 5, 150))
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1)
                        
                        
                        Rectangle()
                          .fill(Color.blue.tertiary)
                          .frame(width: 1, height: 80)
                          .padding(.top, -2)
                    }
                    .offset(y: -44)
                    .animation(.easeInOut(duration: 0.2), value: isActive)
                }
                Spacer()
            }
            
            
            VStack {
                Spacer()
                ZStack(alignment: .top) {
                    // Use the passed capsule width
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: capsuleWidth, height: max(yAxisValue, 10))
                    
                    if isActive {
                        Circle()
                            .fill(Color.white)
                            .frame(width: min(capsuleWidth - 2, 8), height: min(capsuleWidth - 2, 8))
                            .padding(.top, 3)
                            .transition(.scale)
                    }
                }
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Text(xAxisLabel)
                .foregroundColor(Color.gray)
                .font(.system(size: 9, weight: .medium))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.top, 2)
        }
        .offset(y: isActive ? 10 : 0)
        .animation(.easeInOut, value: isActive)
    }
}

extension SleepChartModel: Equatable {
    static func == (lhs: SleepChartModel, rhs: SleepChartModel) -> Bool {
        return lhs.id == rhs.id
    }
}

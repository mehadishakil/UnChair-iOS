//
//  CapsuleChart.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//
//
//import SwiftUI
//
//struct SleepCapsuleChart: View {
//    @State private var currentActiveItem: SleepChartModel?
//    var sleepData: [SleepChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    @State private var dismissTask: DispatchWorkItem?
//    
//    private var displayData: [SleepChartModel] {
//        switch currentTab {
//        case "Week", "Month":
//            return Array(sleepData.reversed())
//        case "Year":
//            return Array(aggregateByMonth(sleepData).reversed())
//        default:
//            return Array(sleepData.reversed())
//        }
//    }
//
//    
//    var body: some View {
//        GeometryReader { geo in
//            ZStack(alignment: .center) {
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(Color.gray.opacity(0.7))
//                    .frame(height: 0.5)
//                    .frame(maxWidth: .infinity)
//                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack(spacing: 0) {
//                        ForEach(displayData) { data in
//                            CapsuleItem(
//                                data: data,
//                                isActive: currentActiveItem?.id == data.id,
//                                xAxisLabel: formatDate(data.date, index: displayData.firstIndex(of: data) ?? 0),
//                                yAxisValue: (data.sleep / 12) * 100
//                            )
//                            .frame(width: max(geo.size.width / CGFloat(displayData.count), 35))
//                            .frame(height: geo.size.height)
//                            .onTapGesture {
//                                dismissTask?.cancel()
//                                currentActiveItem = data
//                                let task = DispatchWorkItem {
//                                    DispatchQueue.main.async {
//                                        if currentActiveItem?.id == data.id {
//                                            currentActiveItem = nil
//                                        }
//                                    }
//                                }
//                                dismissTask = task
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: task)
//                            }
//                        }
//                    }
//                    .scrollTargetBehavior(.paging)
//                    .padding(.horizontal, 10)
//                }
//            }
//        }
//    }
//    
//    private func aggregateByMonth(_ data: [SleepChartModel]) -> [SleepChartModel] {
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
//            let nonZeroItems = items.filter { $0.sleep > 0 }
//            let totalSleep = nonZeroItems.reduce(0) { $0 + $1.sleep }
//            let averageSleep = nonZeroItems.isEmpty ? 0 : totalSleep / Double(nonZeroItems.count)
//            
//            return SleepChartModel(
//                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
//                date: firstDay,
//                sleep: averageSleep
//            )
//        }
//        .sorted { $0.date < $1.date }
//    }
//    
//    
//    private func formatDate(_ date: Date, index: Int) -> String {
//        let formatter = DateFormatter()
//        switch currentTab {
//        case "Week":
//            formatter.dateFormat = "E"
//            return formatter.string(from: date)
//        case "Month":
//            formatter.dateFormat = "dd MMM"
//            return index % 2 == 0 ? formatter.string(from: date) : ""
//        case "Year":
//            formatter.dateFormat = "MMM"
//            return formatter.string(from: date)
//        default:
//            formatter.dateFormat = "MMM yy"
//            return formatter.string(from: date)
//        }
//    }
//}
//
//struct CapsuleItem: View {
//    var data: SleepChartModel
//    var isActive: Bool
//    var xAxisLabel: String
//    var yAxisValue: CGFloat
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        ZStack {
//            VStack {
//                if isActive {
//                    Text("\(data.sleep, specifier: "%.2f") hrs")
//                        .font(.caption)
//                        .padding(4)
//                        .background(
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
//                                .shadow(radius: 2)
//                        )
//                        .lineLimit(1)
//                        .fixedSize(horizontal: true, vertical: false)
//                        .multilineTextAlignment(.center)
//                    
//                    Rectangle()
//                        .fill(Color.gray)
//                        .frame(width: 1, height: 20)
//                        .opacity(0.6)
//                }
//                Spacer()
//            }
//            
//            VStack {
//                Spacer()
//                ZStack(alignment: .top) {
//                    Capsule()
//                        .fill(Color.blue)
//                        .frame(width: 20, height: max(yAxisValue, 10))
//                    
//                    if isActive {
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 8, height: 8)
//                            .padding(.top, 6)
//                    }
//                }
//                Spacer()
//            }
//        }
//        .frame(maxHeight: .infinity)
//        .overlay(alignment: .bottom) {
//            Text(xAxisLabel)
//                .foregroundColor(Color.gray)
//                .font(.system(size: 10, weight: .medium))
//                .fixedSize(horizontal: true, vertical: true)
//                .padding(.top, 4)
//        }
//        .offset(y: isActive ? 10 : 0)
//        .animation(.easeInOut, value: isActive)
//    }
//}
//
//
//
//extension SleepChartModel: Equatable {
//    static func == (lhs: SleepChartModel, rhs: SleepChartModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//}



//
//import SwiftUI
//
//struct SleepCapsuleChart: View {
//    @State private var currentActiveItem: SleepChartModel?
//    var sleepData: [SleepChartModel]
//    @Binding var currentTab: String
//    @Environment(\.colorScheme) var colorScheme
//    @State private var dismissTask: DispatchWorkItem?
//
//    // Get the appropriate data based on current tab
//    private var displayData: [SleepChartModel] {
//        switch currentTab {
//        case "Week":
//            return sleepData.suffix(7) // Last 7 days
//        case "Month":
//            return sleepData.suffix(30) // Last 30 days
//        case "Year":
//            return aggregateByMonth(sleepData).suffix(12) // Last 12 months
//        default:
//            return sleepData
//        }
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            ZStack(alignment: .center) {
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(Color.gray.opacity(0.7))
//                    .frame(height: 0.5)
//                    .frame(maxWidth: .infinity)
//                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
//                
//                HStack(spacing: 0) {
//                    ForEach(displayData) { data in
//                        CapsuleItem(
//                            data: data,
//                            isActive: currentActiveItem?.id == data.id,
//                            xAxisLabel: formatDate(data.date, index: displayData.firstIndex(of: data) ?? 0),
//                            yAxisValue: (data.sleep / 12) * 100
//                        )
//                        // Dynamically adjust capsule width based on available space and data count
//                        .frame(width: calculateItemWidth(geo: geo))
//                        .frame(height: geo.size.height)
//                        .onTapGesture {
//                            dismissTask?.cancel()
//                            currentActiveItem = data
//                            let task = DispatchWorkItem {
//                                DispatchQueue.main.async {
//                                    if currentActiveItem?.id == data.id {
//                                        currentActiveItem = nil
//                                    }
//                                }
//                            }
//                            dismissTask = task
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: task)
//                        }
//                    }
//                }
//                .padding(.horizontal, 10)
//            }
//        }
//    }
//    
//    // Calculate the width for each item based on available space and number of items
//    private func calculateItemWidth(geo: GeometryProxy) -> CGFloat {
//        let availableWidth = geo.size.width - 20 // Account for horizontal padding
//        let count = CGFloat(displayData.count)
//        
//        // Adjust spacing based on the number of items to display
//        let minWidth: CGFloat = 5 // Absolute minimum width
//        let preferredWidth: CGFloat
//        
//        switch currentTab {
//        case "Week":
//            preferredWidth = 35 // Wider capsules for week view
//        case "Month":
//            preferredWidth = 15 // Medium capsules for month view
//        case "Year":
//            preferredWidth = 25 // Wider capsules for year view (12 months)
//        default:
//            preferredWidth = 20
//        }
//        
//        // Calculate width ensuring all items fit within available space
//        return max(min(availableWidth / count, preferredWidth), minWidth)
//    }
//    
//    private func aggregateByMonth(_ data: [SleepChartModel]) -> [SleepChartModel] {
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
//            let nonZeroItems = items.filter { $0.sleep > 0 }
//            let totalSleep = nonZeroItems.reduce(0) { $0 + $1.sleep }
//            let averageSleep = nonZeroItems.isEmpty ? 0 : totalSleep / Double(nonZeroItems.count)
//            
//            return SleepChartModel(
//                id: "month-\(components.year ?? 0)-\(components.month ?? 0)",
//                date: firstDay,
//                sleep: averageSleep
//            )
//        }
//        .sorted { $0.date < $1.date }
//    }
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
//            return index % 5 == 0 ? formatter.string(from: date) : ""
//        case "Year":
//            formatter.dateFormat = "MMM"
//            return formatter.string(from: date)
//        default:
//            formatter.dateFormat = "MMM yy"
//            return formatter.string(from: date)
//        }
//    }
//}
//
//struct CapsuleItem: View {
//    var data: SleepChartModel
//    var isActive: Bool
//    var xAxisLabel: String
//    var yAxisValue: CGFloat
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        ZStack {
//            VStack {
//                if isActive {
//                    Text("\(data.sleep, specifier: "%.1f")h")
//                        .font(.system(size: 9))
//                        .padding(3)
//                        .background(
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
//                                .shadow(radius: 2)
//                        )
//                        .lineLimit(1)
//                        .fixedSize(horizontal: true, vertical: false)
//                        .multilineTextAlignment(.center)
//                    
//                    Rectangle()
//                        .fill(Color.gray)
//                        .frame(width: 1, height: 15)
//                        .opacity(0.6)
//                }
//                Spacer()
//            }
//            
//            VStack {
//                Spacer()
//                ZStack(alignment: .top) {
//                    // Adjust the capsule width based on available space
//                    Capsule()
//                        .fill(Color.blue)
//                        .frame(width: 8, height: max(yAxisValue, 10))
//                    
//                    if isActive {
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 6, height: 6)
//                            .padding(.top, 3)
//                    }
//                }
//                Spacer()
//            }
//        }
//        .frame(maxHeight: .infinity)
//        .overlay(alignment: .bottom) {
//            Text(xAxisLabel)
//                .foregroundColor(Color.gray)
//                .font(.system(size: 8, weight: .medium))
//                .fixedSize(horizontal: true, vertical: true)
//                .padding(.top, 2)
//        }
//        .offset(y: isActive ? 10 : 0)
//        .animation(.easeInOut, value: isActive)
//    }
//}
//
//extension SleepChartModel: Equatable {
//    static func == (lhs: SleepChartModel, rhs: SleepChartModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//}




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
                RoundedRectangle(cornerRadius: 3)
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
                            yAxisValue: (data.sleep / 12) * 100,
                            capsuleWidth: getCapsuleWidth()
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

    var body: some View {
        ZStack {
            VStack {
                if isActive {
                    Text("\(data.sleep, specifier: "%.1f")h")
                        .font(.system(size: 9))
                        .padding(3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
                                .shadow(radius: 2)
                        )
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .scale))
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 15)
                        .opacity(0.6)
                        .transition(.opacity)
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.2), value: isActive)
            
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

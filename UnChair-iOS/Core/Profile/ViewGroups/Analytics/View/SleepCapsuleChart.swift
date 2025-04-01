//
//  CapsuleChart.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//

import SwiftUI

struct SleepCapsuleChart: View {
    @State private var currentActiveItem: SleepChartModel?
    var sleepData: [SleepChartModel]
    @Binding var currentTab: String
    @Environment(\.colorScheme) var colorScheme
    
    private var displayData: [SleepChartModel] {
        switch currentTab {
        case "Week", "Month":
            return sleepData
        case "Year":
            return aggregateByMonth(sleepData)
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
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(displayData) { data in
                            CapsuleItem(
                                data: data,
                                isActive: currentActiveItem?.id == data.id,
                                xAxisLabel: formatDate(data.date, index: displayData.firstIndex(of: data) ?? 0),
                                yAxisValue: (data.sleep / 12) * 100
                            )
                            .frame(width: max(geo.size.width / CGFloat(displayData.count), 35))
                            .frame(height: geo.size.height)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        currentActiveItem = data
                                    }
                                    .onEnded { _ in
                                        currentActiveItem = nil
                                    }
                            )
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .padding(.trailing, 40)
                }
            }
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
            formatter.dateFormat = "dd MMM"
            return index % 2 == 0 ? formatter.string(from: date) : ""
        case "Year":
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if isActive {
                Text("Sleep\(data.sleep, specifier: "%.2f") hrs")
                    .font(.caption)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white)
                            .shadow(radius: 2)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
                
                // Dotted line
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1, height: 20)
                    .opacity(0.6)
                    .padding(.bottom, 4)
            }
            else {
                Spacer()
            }
            
            
            // Capsule
            ZStack(alignment: .top) {
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 20, height: max(yAxisValue, 10))
                
                if isActive {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                }
            }
            
            Spacer()
            
            
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Text(xAxisLabel)
                .foregroundColor(Color.gray)
                .font(.system(size: 10, weight: .medium))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.top, 4)
        }
    }
}


extension SleepChartModel: Equatable {
    static func == (lhs: SleepChartModel, rhs: SleepChartModel) -> Bool {
        return lhs.id == rhs.id
    }
}

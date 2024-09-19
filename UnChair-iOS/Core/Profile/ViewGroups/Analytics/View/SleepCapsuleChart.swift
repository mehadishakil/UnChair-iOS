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
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                
                // Vertical dotted line behind the capsules
                if let activeItem = currentActiveItem {
                    let annotationOffset = self.annotationOffset(for: activeItem, in: geo.size)
                    let itemPosition = itemPosition(for: activeItem, in: geo.size)
                    
                    // Draw vertical dotted line before capsules
                    Path { path in
                        path.move(to: CGPoint(x: itemPosition.x, y: itemPosition.y))
                        path.addLine(to: CGPoint(x: itemPosition.x, y: geo.size.height / 2 + annotationOffset.height))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                    .foregroundColor(.gray)
                }
                
                // Chart bars
                HStack(spacing: 0) {
                    ForEach(sleepData) { data in
                        ItemVerticalStat(
                            xAxisLabel: formatDate(data.date),
                            yAxisValue: (data.sleep / 12) * 100,
                            isActive: currentActiveItem == data
                        )
                        .frame(width: geo.size.width / CGFloat(sleepData.count))
                    }
                }
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.7))
                    .frame(height: 0.5)
                    .frame(maxWidth: .infinity)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2 - 5)
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let widthPerItem = geo.size.width / CGFloat(sleepData.count)
                                let index = min(max(Int(value.location.x / widthPerItem), 0), sleepData.count - 1)
                                currentActiveItem = sleepData[index]
                            }
                            .onEnded { _ in
                                currentActiveItem = nil
                            }
                    )
                
                // Annotation for active item
                if let activeItem = currentActiveItem {
                    let annotationOffset = self.annotationOffset(for: activeItem, in: geo.size)
                    VStack {
                        Text("Sleep\n\(activeItem.sleep, specifier: "%.2f") hrs")
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 5)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(annotationOffset)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch currentTab {
        case "Week":
            formatter.dateFormat = "E"
        case "Month":
            formatter.dateFormat = "dd MMM"
        case "Year":
            formatter.dateFormat = "MMM"
        default:
            formatter.dateFormat = "MMM yy"
        }
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    private func annotationOffset(for item: SleepChartModel, in size: CGSize) -> CGSize {
        guard let index = sleepData.firstIndex(of: item) else { return .zero }
        let widthPerItem = size.width / CGFloat(sleepData.count)
        let xOffset = widthPerItem * CGFloat(index) + widthPerItem / 2 - size.width / 2
        return CGSize(width: xOffset, height: -size.height / 2 + 65)
    }
    
    private func itemPosition(for item: SleepChartModel, in size: CGSize) -> CGPoint {
        guard let index = sleepData.firstIndex(of: item) else { return .zero }
        let widthPerItem = size.width / CGFloat(sleepData.count)
        let xPosition = widthPerItem * CGFloat(index) + widthPerItem / 2
        let yPosition = -size.height / 2 + 65
        return CGPoint(x: xPosition, y: yPosition)
    }
}

struct ItemVerticalStat: View {
    var xAxisLabel: String
    var yAxisValue: CGFloat
    var isActive: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
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
            
            Text(xAxisLabel)
                .foregroundColor(Color.gray)
                .font(.system(size: 10, weight: .medium))
                .fixedSize(horizontal: true, vertical: true)
        }
    }
}

extension SleepChartModel: Equatable {
    static func == (lhs: SleepChartModel, rhs: SleepChartModel) -> Bool {
        return lhs.id == rhs.id
    }
}

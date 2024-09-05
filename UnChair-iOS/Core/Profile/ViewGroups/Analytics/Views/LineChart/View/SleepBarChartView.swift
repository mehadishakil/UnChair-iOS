//
//  SleepingBarChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 17/7/24.
//

import SwiftUI
import Charts

struct SleepBarChartView: View {
    @State private var currentActiveItem: SleepData?
    @State private var plotWidth: CGFloat = 0
    @State private var sleepData: [SleepData] = [
        SleepData(day: "Sat", hours: 6.0),
        SleepData(day: "Sun", hours: 7.5),
        SleepData(day: "Mon", hours: 5.0),
        SleepData(day: "Tue", hours: 8.0),
        SleepData(day: "Wed", hours: 9.0),
        SleepData(day: "Thu", hours: 6.5),
        SleepData(day: "Fri", hours: 7.0)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            sleepInfoView
            chartView
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var sleepInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "moon.zzz.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .padding(.leading)
                    .foregroundColor(.blue)
                Text("Sleep")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text("Avg 8h 2m")
                .font(.caption)
                .padding(.leading)
                .foregroundColor(.gray)
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(sleepData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Hours", data.animate ? data.hours : 0)
                )
                .foregroundStyle(Color.blue)
                .cornerRadius(6)
                
                if let currentActiveItem, currentActiveItem.id == data.id {
                    RuleMark(x: .value("Day", currentActiveItem.day))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .lineStyle(.init(lineWidth: 2))
                        .annotation(position: .top, spacing: 0) { // Add spacing: 0
                            annotationView(for: currentActiveItem)
                        }
                }
            }
        }
        .frame(height: 150) // Increase the height
        .padding(.horizontal, 15)
        .padding(.top, 25) // Increase top padding to accommodate the annotation
        .padding(.bottom, 2)
        .onAppear {
            animateGraph()
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic) { _ in
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 0...(sleepData.map { $0.hours }.max() ?? 0 + 1))
        .chartOverlay(content: chartOverlay)
    }
    
    private func annotationView(for item: SleepData) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(format: "%.1f", item.hours))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 44/255, green: 102/255, blue: 246/255))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(.white.shadow(.drop(radius: 1)))
        }
    }
    
    @ViewBuilder
    private func chartOverlay(content: ChartProxy) -> some View {
        GeometryReader { innerProxy in
            Rectangle()
                .fill(.clear).contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let location = value.location
                            if let day: String = content.value(atX: location.x) {
                                if let currentItem = sleepData.first(where: { $0.day == day }) {
                                    self.currentActiveItem = currentItem
                                    self.plotWidth = content.plotSize.width
                                }
                            }
                        }
                        .onEnded({ value in
                            self.currentActiveItem = nil
                        })
                )
        }
    }
    
    private func animateGraph() {
        for (index, _) in sleepData.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
                    sleepData[index].animate = true
                }
            }
        }
    }
}

struct SleepChartView_Previews: PreviewProvider {
    static var previews: some View {
        SleepBarChartView()
    }
}

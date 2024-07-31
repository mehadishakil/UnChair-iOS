//
//  LineChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI
import Charts

struct LineChartView: View {
    var sampleAnalytics: [SiteView]
    @Binding var currentActiveItem: SiteView?
    @Binding var plotWidth: CGFloat
    
    var body: some View {
        let max = sampleAnalytics.max { $0.views < $1.views }?.views ?? 0
        
        Chart {
            ForEach(sampleAnalytics) { item in
                LineMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Views", item.animate ? item.views : 0)
                )
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Views", item.animate ? item.views : 0)
                )
                .foregroundStyle(.blue.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
                
                if let currentActiveItem, currentActiveItem.id == item.id {
                    RuleMark(x: .value("Day", currentActiveItem.date))
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                        .offset(x: (plotWidth / CGFloat(sampleAnalytics.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Views")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(currentActiveItem.views.stringFormat)
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday())
            }
        }
        .chartYScale(domain: 0...(max + 1000))
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        Calendar.current.isDate(item.date, inSameDayAs: date)
                                    }) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotSize.width
                                    }
                                }
                            }
                            .onEnded({ value in
                                self.currentActiveItem = nil
                            })
                    )
            }
        })
        .frame(height: 180)
    }
}
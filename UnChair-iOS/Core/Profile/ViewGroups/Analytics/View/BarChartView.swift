//
//  BarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var sampleAnalytics: [SiteView]
    @Binding var currentActiveItem: SiteView?
    @Binding var plotWidth: CGFloat
    
    var body: some View {
        let max = sampleAnalytics.max { $0.views < $1.views }?.views ?? 0
        
        Chart(sampleAnalytics) {
                BarMark(
                    x: .value("Day", $0.day),
                    y: .value("Views", $0.animate ? $0.views : 0)
                )
                .foregroundStyle(Color.blue)
                .cornerRadius(6)
                
                if let currentActiveItem, currentActiveItem.id == $0.id{
                    RuleMark(x: .value("Day", currentActiveItem.day))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .lineStyle(.init(lineWidth: 2))
                        .annotation(position: .top, spacing: 0){
                            annotationView(for: currentActiveItem)
                        }
                }
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
        .chartYScale(domain: 0...(max + 1000))
        .chartOverlay(content: chartOverlay)
        .frame(height: 180)
    }
    
    @ViewBuilder
    private func chartOverlay(content: ChartProxy) -> some View{
        GeometryReader{ innerProxy in
            Rectangle()
                .fill(.clear).contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ value in
                            let location = value.location
                            if let day: String = content.value(atX: location.x){
                                if let currentItem = sampleAnalytics.first(where: {
                                    $0.day == day}){
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
    
    private func annotationView(for item: SiteView) -> some View{
        VStack(alignment: .leading, spacing: 2){
            Text(item.views.stringFormat)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(Color(red: 44/255, green: 102/255, blue: 246/255))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(.white.shadow(.drop(radius: 1)))
        }
    }
}

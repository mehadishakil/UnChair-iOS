//
//  SleepingBarChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 17/7/24.
//

import SwiftUI
import Charts

struct SleepData: Identifiable {
    let id = UUID()
    let day: String
    let hours: Double
    var animate: Bool = false
}

struct SleepChartView: View {
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
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Image("sleepy_emoji")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
                    .padding(.leading)
                
                Text("Avg Sleep")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text("8h 2m")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
            }
            
            Chart {
                ForEach(sleepData) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Hours", data.animate ? data.hours : 0)
                    )
                    .foregroundStyle(Color.blue)
                    .cornerRadius(6)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 130)
            .padding(.vertical, 15)
            .onAppear {
                animateGraph()
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    func animateGraph() {
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
        SleepChartView()
    }
}

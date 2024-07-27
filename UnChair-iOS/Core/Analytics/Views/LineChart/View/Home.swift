//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI

struct Home: View {
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var currentTab: String = "7 Days"
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Views")
                            .fontWeight(.semibold)

                        Picker("", selection: $currentTab) {
                            Text("7 Days")
                                .tag("7 Days")
                            Text("Week")
                                .tag("Week")
                            Text("Month")
                                .tag("Month")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 80)
                    }

                    let totalValue = sampleAnalytics.reduce(0.0) { partialResult, item in
                        item.views + partialResult
                    }

                    Text(totalValue.stringFormat)
                        .font(.title.bold())

                    // Call the chart components
                    BarChartView(sampleAnalytics: sampleAnalytics, currentActiveItem: $currentActiveItem, plotWidth: $plotWidth)
                    LineChartView(sampleAnalytics: sampleAnalytics, currentActiveItem: $currentActiveItem, plotWidth: $plotWidth)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 8)))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Swift Charts")
            .onChange(of: currentTab) { oldValue, newValue in
                sampleAnalytics = sample_analytics
                if newValue != "7 Days" {
                    for (index, _) in sampleAnalytics.enumerated() {
                        sampleAnalytics[index].views = .random(in: 1500...10000)
                    }
                }
                animateGraph(fromChange: true)
            }
        }
    }

    func animateGraph(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
}

#Preview {
    Home()
}



extension Double{
    var stringFormat: String{
        if self >= 10000 && self < 999999{
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999{
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", self)
    }
}




//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI

struct WaterLineChartView: View {
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0

    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 2) {
                
                HStack{
                    Image(systemName: "mug.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundColor(.blue)
                    Text("Water")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                    
  
                    let totalValue = sampleAnalytics.reduce(0.0) { $0 + $1.views }
                    
                    Text("Avg \(totalValue.stringFormat) ml")
                    .font(.caption2)
                    .foregroundColor(.gray)

                    LineChartView(sampleAnalytics: sampleAnalytics, currentActiveItem: $currentActiveItem, plotWidth: $plotWidth)
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 8)
        }
        .onAppear {
            animateGraph()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Weekly Chart")
    }
    
    func animateGraph() {
        withAnimation(.easeInOut(duration: 0.8)) {
            for index in sampleAnalytics.indices {
                sampleAnalytics[index].animate = true
            }
        }
    }
}

#Preview {
    WaterLineChartView()
}



// Add this extension back
extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", self)
    }
}

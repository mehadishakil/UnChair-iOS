//
//  StepsBarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/8/24.
//

import SwiftUI

struct StepsBarChartView: View {
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                
                HStack{
                    Image(systemName: "figure.walk")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundColor(.blue)
                    Text("Steps")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                    
                    
                    
                    let totalValue = sampleAnalytics.reduce(0.0) { $0 + $1.views }
                    
                    Text("Avg \(totalValue.stringFormat) steps")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                
                
                
                
                    BarChartView(sampleAnalytics: sampleAnalytics, currentActiveItem: $currentActiveItem, plotWidth: $plotWidth)
                
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
    StepsBarChartView()
}

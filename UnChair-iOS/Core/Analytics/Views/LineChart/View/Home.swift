//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI
import Charts


struct Home: View {
    // MARK: State Chart Data For Animation Changes
    @State var sampleAnalytics: [SiteView] = sample_analytics

    // MARK: View Properties
    @State var currentTab: String = "7 Days"

    var body: some View {
        NavigationStack{
            VStack{
                // MARK: New Chart API
                VStack(alignment: .leading, spacing: 12){
                    HStack{
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
                        .font(.largeTitle.bold())
                    
                    AnimatedChart()
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 2)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle("Swift Charts")
            .onChange(of: currentTab) { oldValue, newValue in
                sampleAnalytics = sample_analytics
                if newValue != "7 Days" {
                    for (index, _) in sampleAnalytics.enumerated() {
                        sampleAnalytics[index].views = .random(in: 1500...10000)
                    }
                }
                
                // Re-animating View
                animateGraph(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View{
        let max = sampleAnalytics.max { item1, item2 in
            return item2.views > item1.views
        }?.views ?? 0
        
        Chart{
            ForEach(sampleAnalytics){item in
                // MARK: Bar Graph
                BarMark(
                    x: .value("Hour", item.hour,unit: .hour),
                    y: .value("Views", item.animate ? item.views : 0)
                )
                
            }
        }
        // MARK: Customizing Y-Axis Length
        .chartYScale(domain: 0...(max + 5000))
        .chartOverlay(content: {proxy in
            GeometryReader{innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{value in
                                let location = value.location
                                
                                if let date : Date = proxy.value(atX: location.x){
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: date)
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        calendar.component(.hour, from: item.hour) == hour
                                    }){
                                        print(currentItem.views)
                                    }
                                }
                                
                            }.onEnded({ value in
                                
                            })
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            animateGraph()
        }
    }
    
    
    // animting graph
    func animateGraph(fromChange: Bool = false){
        for (index,_) in sampleAnalytics.enumerated(){
            // For Some Reason Delay is Not Working
            // Using Dispatch Queue Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * ( fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
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



// time : 11:00

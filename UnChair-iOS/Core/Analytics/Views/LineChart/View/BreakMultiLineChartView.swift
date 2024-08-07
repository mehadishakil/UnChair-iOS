//
//  MultiLineChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/7/24.
//

import SwiftUI
import Charts

struct BreakMultiLineChartView: View {
    @State private var selectedCity = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Exercise Stats")
                    .fontWeight(.semibold)
                Spacer()
                citySelectionMenu
            }
            .padding()
            
            ChartContentView(selectedCity: $selectedCity)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .frame(maxWidth: .infinity, minHeight: 350, maxHeight: 900, alignment: .top)
    }
    
    private var citySelectionMenu: some View {
        Menu {
            Button("New York") { selectedCity = 0 }
            Button("Amsterdam") { selectedCity = 1 }
            Button("London") { selectedCity = 2 }
            Button("Toronto") { selectedCity = 3 }
        } label: {
            Text("Select City")
        }
    }
}

struct ChartContentView: View {
    @Binding var selectedCity: Int
    
    var body: some View {
        Chart {
            ForEach(CityWeatherData.cityRain, id:\.city) { city in
                ForEach(city.data) { weather in
                    LineMark(
                        x: .value("Month", weather.month),
                        y: .value("Rainfall", weather.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: city.city == CityWeatherData.citydata[selectedCity].0 ? 6.0 : 2.0))
                    
                    PointMark(
                        x: .value("Month", weather.month),
                        y: .value("Rainfall", weather.value)
                    )
                }
                .foregroundStyle(by: .value("City", city.city))
            }
        }
        .chartForegroundStyleScale([
            CityWeatherData.citydata[0].0 : CityWeatherData.citydata[0].2,
            CityWeatherData.citydata[1].0 : CityWeatherData.citydata[1].2,
            CityWeatherData.citydata[2].0 : CityWeatherData.citydata[2].2,
            CityWeatherData.citydata[3].0 : CityWeatherData.citydata[3].2,
        ])
        .chartSymbolScale([
            "New York": Circle().strokeBorder(lineWidth: 2),
            "Amsterdam": Circle().strokeBorder(lineWidth: 2),
            "London": Circle().strokeBorder(lineWidth: 2),
            "Toronto": Circle().strokeBorder(lineWidth: 2),
        ])
        .chartOverlay { proxy in
            GeometryReader { geo in
                chartOverlay(proxy: proxy, geo: geo)
            }
        }
        
    }
    
    @ViewBuilder
    private func chartOverlay(proxy: ChartProxy, geo: GeometryProxy) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded { value in
//                            let location = value.location
//                            if let city = CityWeatherData.cityRain.first(where: { city in
//                                city.data.contains(where: { weather in
//                                    let pointLocation = proxy.plotLocation(for: .value("Month", weather.month), .value("Rainfall", weather.value))
//                                    return geo.frame(in: .global).contains(pointLocation)
//                                })
//                            })?.city {
//                                withAnimation {
//                                    self.selectedCity = city
//                                }
//                            }
                            
                        }
                )
        }
    }
    
}

#Preview {
    BreakMultiLineChartView()
}

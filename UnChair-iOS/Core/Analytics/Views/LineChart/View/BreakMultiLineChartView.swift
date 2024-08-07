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
        VStack(alignment: .leading, spacing: 2) {
            HStack{
                Image(systemName: "figure.mixed.cardio")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .foregroundColor(.blue)
                Text("Breaks")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text("Avg 45 min")
                .font(.caption2)
                .foregroundColor(.gray)
            
            ChartContentView(selectedCity: $selectedCity)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 900, alignment: .top)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        
        
    }
    
    
}

struct ChartContentView: View {
    @Binding var selectedCity: Int
    @State private var tappedCity: String?
    
    var body: some View {
        Chart {
            ForEach(CityWeatherData.cityRain, id:\.city) { city in
                ForEach(city.data) { weather in
                    LineMark(
                        x: .value("Month", weather.month),
                        y: .value("Rainfall", weather.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: city.city == tappedCity ? 4.0 : 2.0))
                    
                    PointMark(
                        x: .value("Month", weather.month),
                        y: .value("Rainfall", weather.value)
                    )
                    .symbolSize(city.city == tappedCity ? 100 : 50)
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
    
    func chartOverlay(proxy: ChartProxy, geo: GeometryProxy) -> some View {
        Rectangle().fill(.clear).contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0) // Capture taps by setting minimumDistance to 0
                    .onEnded { value in
                        let location = value.location // Get the tap location
                        
                        var closestCity: String?
                        var minDistance: CGFloat = .infinity
                        
                        for cityData in CityWeatherData.cityRain {
                            for weather in cityData.data {
                                if let xPosition = proxy.position(forX: weather.month) {
                                    if let yPosition = proxy.position(forY: weather.value) {
                                        let point = CGPoint(x: xPosition, y: yPosition)
                                        let currentDistance = distance(from: location, to: point)
                                        if currentDistance < minDistance {
                                            minDistance = currentDistance
                                            closestCity = cityData.city
                                        }
                                    }
                                }
                            }
                        }
                        tappedCity = closestCity
                    }
            )
    }
    
    private func distance(from point: CGPoint, to linePoint: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - linePoint.x, 2) + pow(point.y - linePoint.y, 2))
    }
}

#Preview {
    BreakMultiLineChartView()
}

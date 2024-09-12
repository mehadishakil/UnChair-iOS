//
//  MultiLineChartModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/7/24.
//

import Foundation
import SwiftUI

// basic struct to hold some weather data - rainfall
struct WeatherData: Identifiable {
    var id = UUID()
    var month: String
    var value: Int
}

struct CityWeatherData {
    // array of city data and colors with flags
    static let citydata : [(String, String, Color)] = [
        ("New York", "🇺🇸", .red),
        ("Amsterdam", "🇳🇱", .orange),
        ("London", "🏴", .blue),
        ("Toronto", "🇨🇦", .yellow),
    ]
    
    // an array containing a city and some data
    static var cityRain = [
        (city: "New York", data:[
            WeatherData(month: "Jan", value: 81),
            WeatherData(month: "Feb", value: 91),
            WeatherData(month: "Mar", value: 97),
            WeatherData(month: "Apr", value: 96),
            WeatherData(month: "May", value: 99),
            WeatherData(month: "Jun", value: 95),
            WeatherData(month: "Jul", value: 97),
            WeatherData(month: "Aug", value: 93),
            WeatherData(month: "Sep", value: 98),
            WeatherData(month: "Oct", value: 94),
            WeatherData(month: "Nov", value: 99),
            WeatherData(month: "Dec", value: 89),
        ]),
        (city: "Amsterdam", data:[
            WeatherData(month: "Jan", value: 81),
            WeatherData(month: "Feb", value: 90),
            WeatherData(month: "Mar", value: 87),
            WeatherData(month: "Apr", value: 86),
            WeatherData(month: "May", value: 89),
            WeatherData(month: "Jun", value: 85),
            WeatherData(month: "Jul", value: 87),
            WeatherData(month: "Aug", value: 83),
            WeatherData(month: "Sep", value: 88),
            WeatherData(month: "Oct", value: 84),
            WeatherData(month: "Nov", value: 89),
            WeatherData(month: "Dec", value: 95),
        ]),
        (city: "London", data:[
            WeatherData(month: "Jan", value: 70),
            WeatherData(month: "Feb", value: 71),
            WeatherData(month: "Mar", value: 77),
            WeatherData(month: "Apr", value: 76),
            WeatherData(month: "May", value: 79),
            WeatherData(month: "Jun", value: 75),
            WeatherData(month: "Jul", value: 77),
            WeatherData(month: "Aug", value: 73),
            WeatherData(month: "Sep", value: 78),
            WeatherData(month: "Oct", value: 74),
            WeatherData(month: "Nov", value: 79),
            WeatherData(month: "Dec", value: 79),
        ]),
        (city: "Toronto", data:[
            WeatherData(month: "Jan", value: 60),
            WeatherData(month: "Feb", value: 61),
            WeatherData(month: "Mar", value: 67),
            WeatherData(month: "Apr", value: 66),
            WeatherData(month: "May", value: 69),
            WeatherData(month: "Jun", value: 65),
            WeatherData(month: "Jul", value: 67),
            WeatherData(month: "Aug", value: 63),
            WeatherData(month: "Sep", value: 68),
            WeatherData(month: "Oct", value: 64),
            WeatherData(month: "Nov", value: 69),
            WeatherData(month: "Dec", value: 69),
        ]),
    ]
}

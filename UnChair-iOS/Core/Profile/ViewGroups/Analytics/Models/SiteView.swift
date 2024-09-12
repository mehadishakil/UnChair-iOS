//
//  SiteView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI

struct SiteView: Identifiable {
    var id = UUID().uuidString
    var day: String
    var views: Double
    var animate: Bool = false
}

struct SleepData: Identifiable {
    let id = UUID()
    let day: String
    var hours: Double
    var animate: Bool = false
}

extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
}

// Updated sample data with weekly data
var sample_analytics: [SiteView] = [
    SiteView(day: "Sun", views: 20988),
    SiteView(day: "Mon", views: 25500),
    SiteView(day: "Tue", views: 22625),
    SiteView(day: "Wed", views: 27500),
    SiteView(day: "Thu", views: 23688),
    SiteView(day: "Fri", views: 29988),
    SiteView(day: "Sat", views: 31500),
]

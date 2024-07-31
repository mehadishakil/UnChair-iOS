//
//  SiteView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI

struct SiteView: Identifiable {
    var id = UUID().uuidString
    var date: Date
    var views: Double
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
let sample_analytics: [SiteView] = [
    SiteView(date: Date().addingTimeInterval(-6 * 24 * 3600), views: 20988),
    SiteView(date: Date().addingTimeInterval(-5 * 24 * 3600), views: 25500),
    SiteView(date: Date().addingTimeInterval(-4 * 24 * 3600), views: 22625),
    SiteView(date: Date().addingTimeInterval(-3 * 24 * 3600), views: 27500),
    SiteView(date: Date().addingTimeInterval(-2 * 24 * 3600), views: 23688),
    SiteView(date: Date().addingTimeInterval(-1 * 24 * 3600), views: 29988),
    SiteView(date: Date(), views: 31500),
]

//
//  BreakTimeModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/8/24.
//

import Foundation

struct TimeDuration: Codable, Equatable {
    var hours: Int
    var minutes: Int
    
    var totalMinutes: Int {
        return hours * 60 + minutes
    }
    
    init(hours: Int = 0, minutes: Int = 0) {
        self.hours = hours
        self.minutes = minutes
    }
    
    init(fromTotalMinutes total: Int) {
        self.hours = total / 60
        self.minutes = total % 60
    }
    
}



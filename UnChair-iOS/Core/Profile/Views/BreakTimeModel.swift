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
}



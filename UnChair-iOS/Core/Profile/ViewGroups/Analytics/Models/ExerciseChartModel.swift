//
//  ExerciseChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 16/9/24.
//

import Foundation
import SwiftData


@Model
class ExerciseChartModel {
    @Attribute(.unique) var id: String
    var date: Date
    var breaks: Breaks
    var lastUpdated: Date
    var isSynced: Bool
    
    init(id: String, date: Date = .now, breaks: Breaks, lastUpdated: Date, isSynced: Bool = false) {
        self.id = id
        self.date = date
        self.breaks = breaks
        self.lastUpdated = lastUpdated
        self.isSynced = isSynced
    }
}


struct Breaks: Codable {
    var quickBreak: Double
    var shortBreak: Double
    var mediumBreak: Double
    var longBreak: Double
}

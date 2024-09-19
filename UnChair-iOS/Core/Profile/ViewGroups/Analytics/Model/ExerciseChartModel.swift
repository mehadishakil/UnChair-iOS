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
    var breakEntries: [BreakEntry]
    var lastUpdated: Date
    var isSynced: Bool
    
    init(id: String, date: Date = .now, breakEntries: [BreakEntry], lastUpdated: Date, isSynced: Bool = false) {
        self.id = id
        self.date = date
        self.breakEntries = breakEntries
        self.lastUpdated = lastUpdated
        self.isSynced = isSynced
    }
}

struct BreakEntry: Codable {
    var breakType: String // e.g., "Quick Break", "Short Break"
    var breakValue: Double
}

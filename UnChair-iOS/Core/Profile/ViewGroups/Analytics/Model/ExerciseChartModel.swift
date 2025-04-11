//
//  ExerciseChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 16/9/24.
//

import Foundation
import SwiftData

@Model
class ExerciseChartModel : Identifiable {
    var id: String
    var date: Date
    var breakEntries: [BreakEntry]

    
    init(id: String = UUID().uuidString, date: Date, breakEntries: [BreakEntry]) {
        self.id = id
        self.date = date
        self.breakEntries = breakEntries
    }
}

struct BreakEntry: Codable {
    var breakType: String // e.g., "Quick Break", "Short Break"
    var breakValue: Double
}


//struct ExerciseBreakDataPoint: Identifiable, Hashable {
//    var id = UUID()
//    var date: Date
//    var breakType: String
//    var breakValue: Double
//}

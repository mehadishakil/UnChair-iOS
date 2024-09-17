//
//  SleepChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//

import Foundation
import SwiftData

@Model
class SleepChartModel{
    @Attribute(.unique) var id: String    // Unique identifier (UUID)
    var date: Date                        // Date of record
    var sleep: Double               // Amount of water consumed in ml
    var lastUpdated: Date                 // Timestamp for sync purpose
    var isSynced: Bool                    // Sync flag to mark if synced with Firebase
    
    init(id: String, date: Date = .now, sleep: Double = 0.0, lastUpdated: Date, isSynced: Bool = false) {
        self.id = id
        self.date = date
        self.sleep = sleep
        self.lastUpdated = lastUpdated
        self.isSynced = isSynced
    }
    
//    func dayOfWeek() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "E"
//        return dateFormatter.string(from: self.date)
//    }
}

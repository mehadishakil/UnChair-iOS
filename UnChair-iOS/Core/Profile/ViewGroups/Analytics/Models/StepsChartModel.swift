//
//  StepsChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//

import Foundation
import SwiftData

@Model
class StepsChartModel {
    @Attribute(.unique) var id: String    // Unique identifier (UUID)
    var date: Date                        // Date of record
    var steps: Int               // Amount of water consumed in ml
    var lastUpdated: Date                 // Timestamp for sync purpose
    var isSynced: Bool                    // Sync flag to mark if synced with Firebase
    
    init(id: String, date: Date = .now, steps: Int = 0, lastUpdated: Date, isSynced: Bool = false) {
        self.id = id
        self.date = date
        self.steps = steps
        self.lastUpdated = lastUpdated
        self.isSynced = isSynced
    }
    
}

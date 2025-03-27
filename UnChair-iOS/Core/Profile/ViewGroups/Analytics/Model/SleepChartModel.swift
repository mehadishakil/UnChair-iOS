//
//  SleepChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//

import Foundation
import SwiftData

@Model
class SleepChartModel : Identifiable {
    var id: String                  // Unique identifier (UUID)
    var date: Date                  // Date of record
    var sleep: Double               // Amount of water consumed in ml
    
    init(id: String = UUID().uuidString, date: Date, sleep: Double = 0.0) {
        self.id = id
        self.date = date
        self.sleep = sleep
    }
}

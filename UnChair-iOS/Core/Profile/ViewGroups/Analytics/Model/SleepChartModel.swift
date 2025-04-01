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
    var id: String
    var date: Date
    var sleep: Double
    
    init(id: String = UUID().uuidString, date: Date, sleep: Double) {
        self.id = id
        self.date = date
        self.sleep = sleep
    }
}

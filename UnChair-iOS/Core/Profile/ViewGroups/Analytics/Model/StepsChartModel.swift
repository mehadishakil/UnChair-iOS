//
//  StepsChartModel.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//

import Foundation
import SwiftData

@Model
class StepsChartModel : Identifiable {
    var id: String               // Unique identifier (UUID)
    var date: Date               // Date of record
    var steps: Int               // Amount of water consumed in ml
    
    init(id: String = UUID().uuidString, date: Date, steps: Int) {
        self.id = id
        self.date = date
        self.steps = steps
    }
    
}

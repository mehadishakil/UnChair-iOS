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
    var id: String
    var date: Date
    var steps: Int
    
    init(id: String = UUID().uuidString, date: Date, steps: Int) {
        self.id = id
        self.date = date
        self.steps = steps
    }
    
}

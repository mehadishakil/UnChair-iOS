//
//  MeditationChartModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 8/4/25.
//
import Foundation
import SwiftData

@Model
class MeditationChartModel: Identifiable {
    var id: String
    var date: Date
    var duration: Double
    
    init(id: String = UUID().uuidString, date: Date, duration: Double) {
        self.id = id
        self.date = date
        self.duration = duration
    }
    
}

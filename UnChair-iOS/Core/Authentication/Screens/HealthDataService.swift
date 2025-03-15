//
//  HealthDataService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/2/25.
//

import Foundation
import FirebaseFirestore

struct HealthDataService {
    private let db = Firestore.firestore()

    func updateDailyHealthData(
        for userId: String,
        date: Date,
        waterIntake: Int?,
        stepsTaken: Int?,
        sleepDuration: Float?,
        exerciseTime: [String: Int]?
    ) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"
        
        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        
        var updatedData: [String: Any] = [:]
        
        if let water = waterIntake {
            updatedData["waterIntake"] = water
        }
        if let steps = stepsTaken {
            updatedData["stepsTaken"] = steps
        }
        if let sleep = sleepDuration {
            updatedData["sleepDuration"] = sleep
        }
        if let exercise = exerciseTime {
            updatedData["exerciseTime"] = exercise
        }
        
        try await logRef.setData(updatedData, merge: true)
        print("Daily health data for \(documentName) updated successfully.")
    }

    // Function to fetch daily sleep data
    func fetchTodaysSleepData(for userId: String, date: Date) async throws -> Float? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"

        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        
        let document = try await logRef.getDocument()
        
        if let data = document.data(), let sleepDuration = data["sleepDuration"] as? Float {
            return sleepDuration
        } else {
            return nil
        }
    }
    
    func fetchTodaysWaterData(for userId: String, date: Date) async throws -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"

        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        
        print("Hello")
        
        let document = try await logRef.getDocument()
        
        if let data = document.data(), let waterIntake = data["waterIntake"] as? Int {
            return waterIntake
        } else {
            return nil
        }
    }
}

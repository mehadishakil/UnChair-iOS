//
//  HealthDataService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/2/25.
//

import Foundation
import FirebaseFirestore

struct HealthDataService {
    func updateDailyHealthData(
        for userId: String,
        date: Date,
        waterIntake: Int?,         // New or updated water intake value
        stepsTaken: Int?,          // New or updated steps count
        sleepDuration: Int?,       // New or updated sleep duration in minutes
        exerciseTime: [String: Int]?  // New or updated exercise time data
    ) async throws {
        // Format the date to create a document name, e.g., "daily_log_2025_02_20"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"
        
        // Reference the user's daily log document in the health_data sub-collection
        let logRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        
        // Prepare the data dictionary with only the fields you want to update
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
            // This will update the entire exerciseTime map.
            // If you want to update specific nested fields, you can use dot notation like:
            // updatedData["exerciseTime.quick_break"] = exercise["quick_break"]
            updatedData["exerciseTime"] = exercise
        }
        
        // Update the document; merge: true ensures that only the fields in updatedData are updated.
        try await logRef.setData(updatedData, merge: true)
        print("Daily health data for \(documentName) updated successfully.")
    }
}

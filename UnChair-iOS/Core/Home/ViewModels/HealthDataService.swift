//
//  HealthDataService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/2/25.
//

import Foundation
import FirebaseFirestore
import HealthKit

class HealthDataService {
    private let db = Firestore.firestore()
    var healthStore: HKHealthStore?
    @Published var todayStepCount: Int = 0

    init() {
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]

        Task {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                do {
                    try await healthStore!.requestAuthorization(toShare: [], read: healthTypes)
                    fetchTodaySteps() // Fetch steps after getting authorization
                } catch {
                    print("Error fetching health data")
                }
            } else {
                print("Your device does not support health services")
            }
        }
    }


    func updateDailyHealthData(
        for userId: String,
        date: Date,
        waterIntake: Int?,
        stepsTaken: Int?,
        sleepDuration: Float?,
        meditationDuration: Int?,
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
        if let meditation = meditationDuration {
            updatedData["meditationDuration"] = meditation
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
        

        let document = try await logRef.getDocument()
        
        if let data = document.data(), let waterIntake = data["waterIntake"] as? Int {
            return waterIntake
        } else {
            return nil
        }
    }
    
    func fetchTodaySteps()-> Int {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { [weak self] _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's step data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            DispatchQueue.main.async {
                self?.todayStepCount = Int(stepCount)
            }
        }
        healthStore!.execute(query)
        
        return todayStepCount
    }
    
    func fetchTodaysMeditationData(for userId: String, date: Date) async throws -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"

        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        

        let document = try await logRef.getDocument()
        
        if let data = document.data(), let waterIntake = data["meditationDuration"] as? Int {
            return waterIntake
        } else {
            return nil
        }
    }
}

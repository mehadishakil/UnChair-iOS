//
//  HealthDataService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/2/25.
//

import Foundation
import FirebaseFirestore
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthDataService {
    private let db = Firestore.firestore()
    var healthStore: HKHealthStore?
    @Published var todayStepCount: Int = 0

    init() {
        if HKHealthStore.isHealthDataAvailable() {
                    healthStore = HKHealthStore()
                } else {
                    print("Your device does not support health services")
                }
    }
    
    // request authorization
        func requestHealthDataPermission() async throws {
            guard let healthStore = healthStore else {
                throw HealthDataServiceError.healthStoreNotAvailable
            }
            
            let steps = HKQuantityType(.stepCount)
            let healthTypes: Set = [steps]
            
            try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            // Optionally, fetch today's steps immediately after authorization
            try await fetchTodaySteps()
        }


    func updateDailyHealthData(
        for userId: String,
        date: Date,
        waterIntake: Int?,
        stepsTaken: Int?,
        sleepDuration: Int?,
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
    func fetchTodaysSleepData(for userId: String, date: Date) async throws -> Int? { // Changed to Int?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"

        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)

        let document = try await logRef.getDocument()

        // Ensure sleepDuration is stored and retrieved as Int
        if let data = document.data(), let sleepDuration = data["sleepDuration"] as? Int { // Changed to Int
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
    
    // In HealthDataService.swift
    func fetchTodaySteps() async throws -> Int { // Changed signature
        return try await withCheckedThrowingContinuation { continuation in
            guard let healthStore = healthStore else {
                continuation.resume(throwing: HealthDataServiceError.healthStoreNotAvailable)
                return
            }

            let steps = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { [weak self] _, result, error in
                if let error = error {
                    print("Error fetching today's step data: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let quantity = result?.sumQuantity() else {
                    continuation.resume(returning: 0) // No steps found, return 0
                    return
                }

                let stepCount = quantity.doubleValue(for: .count())
                DispatchQueue.main.async {
                    self?.todayStepCount = Int(stepCount) // Still update published property if needed elsewhere
                }
                continuation.resume(returning: Int(stepCount))
            }
            healthStore.execute(query)
        }
    }

    // You might want to define a custom error for clarity
    enum HealthDataServiceError: Error {
        case healthStoreNotAvailable
        case healthKitQueryFailed(Error)
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
    
    func fetchTodaysExerciseData(for userId: String, date: Date) async throws -> [String: Int]? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        let dateString = dateFormatter.string(from: date)
        let documentName = "daily_log_\(dateString)"

        let logRef = db.collection("users")
            .document(userId)
            .collection("health_data")
            .document(documentName)
        
        let document = try await logRef.getDocument()
        
        if let data = document.data(), let exerciseTime = data["exerciseTime"] as? [String: Int] {
            return exerciseTime
        } else {
            return nil
        }
    }
}

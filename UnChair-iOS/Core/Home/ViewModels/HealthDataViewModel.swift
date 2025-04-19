//
//  HealthDataViewModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 17/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class HealthDataViewModel: ObservableObject {
    @Published var waterIntake: Int = 0
    @Published var sleepHours: Float = 0
    @Published var stepCount: Int = 0
    @Published var isLoading: Bool = true
    @Published var dailyData: [String: Any] = [:]
    
    private let healthService = HealthDataService()
    private let firestoreService = FirestoreService()
    private var userId: String?
    private var firestoreListener: ListenerRegistration?
    private var today: String {
        return DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    }
    
    init() {
        // Initially check if user is signed in and start listening
        if let currentUser = Auth.auth().currentUser {
            setUserId(currentUser.uid)
        }
    }
    
    deinit {
        removeListener()
    }
    
    func setUserId(_ id: String) {
        userId = id
        setupFirestoreListener()
        loadAllData()
    }
    
    func loadAllData() {
        guard let userId = userId else { return }
        isLoading = true
        
        Task {
            do {
                async let waterTask  = try healthService.fetchTodaysWaterData(for: userId, date: Date())
                async let sleepTask  = try healthService.fetchTodaysSleepData(for: userId, date: Date())
                async let stepsTask  = try healthService.fetchTodaySteps()    // or fetchTodaySteps(for: userId, date: Date())

                let (water, sleep, steps) = await try (waterTask, sleepTask, stepsTask)

                await MainActor.run {
                    self.waterIntake = water  ?? 0
                    self.sleepHours  = sleep  ?? 0
                    self.stepCount   = steps  ?? 0
                    self.isLoading   = false

                    self.syncDataToFirestore()
                }

            } catch {
                print("Error loading health data: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func setupFirestoreListener() {
        // First remove any existing listener
        removeListener()
        
        guard let userId = userId else { return }
        
        // Setup a new listener
        let userDoc = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("health_data")
            .document(today)
        
        firestoreListener = userDoc.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for data: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.dailyData = data
                    // Update the published properties from Firestore data
                    self.waterIntake = data["waterConsumption"] as? Int ?? self.waterIntake
                    self.sleepHours = data["sleep"] as? Float ?? self.sleepHours
                    self.stepCount = data["steps"] as? Int ?? self.stepCount
                }
            } else {
                // Document doesn't exist, create it
                self.createInitialDocument()
            }
        }
    }
    
    private func removeListener() {
        firestoreListener?.remove()
        firestoreListener = nil
    }
    
    private func createInitialDocument() {
        guard let userId = userId else { return }
        
        let initialData: [String: Any] = [
            "steps": stepCount,
            "waterConsumption": waterIntake,
            "sleep": sleepHours,
            "activities": [],
            "lastUpdated": Date()
        ]
        
        firestoreService.createDocument(for: today, initialData: initialData) { error in
            if let error = error {
                print("Error creating document: \(error.localizedDescription)")
            } else {
                print("Initial document created successfully")
                self.dailyData = initialData
            }
        }
    }
    
    private func syncDataToFirestore() {
        guard let userId = userId else { return }
        
        let updatedData: [String: Any] = [
            "steps": stepCount,
            "waterConsumption": waterIntake,
            "sleep": sleepHours,
            "lastUpdated": Date()
        ]
        
        firestoreService.syncData(for: today, updatedData: updatedData) { error in
            if let error = error {
                print("Error syncing data: \(error.localizedDescription)")
            } else {
                print("Data synced successfully!")
            }
        }
    }
    
    // MARK: - Update Methods
    
    func updateWaterIntake(_ amount: Int) {
        self.waterIntake = amount
        
        Task {
            do {
                if let userId = userId {
                    try await healthService.updateDailyHealthData(
                        for: userId,
                        date: Date(),
                        waterIntake: amount,
                        stepsTaken: nil,
                        sleepDuration: nil,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating water intake: \(error.localizedDescription)")
            }
        }
    }
    
    func updateSleepHours(_ hours: Float) {
        self.sleepHours = hours
        
        Task {
            do {
                if let userId = userId {
                    try await healthService.updateDailyHealthData(
                        for: userId,
                        date: Date(),
                        waterIntake: nil,
                        stepsTaken: nil,
                        sleepDuration: hours,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating sleep hours: \(error.localizedDescription)")
            }
        }
    }
    
    func updateStepCount(_ steps: Int) {
        self.stepCount = steps
        
        Task {
            do {
                if let userId = userId {
                    try await healthService.updateDailyHealthData(
                        for: userId,
                        date: Date(),
                        waterIntake: nil,
                        stepsTaken: steps,
                        sleepDuration: nil,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating step count: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshData() {
        loadAllData()
    }
}

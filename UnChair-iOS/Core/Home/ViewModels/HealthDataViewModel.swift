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
    @Published var sleepMinutes: Int = 0  // Changed from sleepHours to sleepMinutes
    @Published var stepCount: Int = 0
    @Published var meditationDuration: Int = 0
    @Published var isLoading: Bool = true
    @Published var dailyData: [String: Any] = [:]
    @Published var errorMessage: String?
    
    let healthService = HealthDataService()
    private let firestoreService = FirestoreService()
    private var userId: String?
    private var firestoreListener: ListenerRegistration?
    private var today: String {
        return DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    }
    
    init() {
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
                async let waterTask = try healthService.fetchTodaysWaterData(for: userId, date: Date())
                async let sleepTask = try healthService.fetchTodaysSleepData(for: userId, date: Date())
                async let stepsTask = try healthService.fetchTodaySteps()
                async let meditationTask = try healthService.fetchTodaysMeditationData(for: userId, date: Date())

                let (water, minutes, steps, meditation) = await try (waterTask, sleepTask, stepsTask, meditationTask)
                await MainActor.run {
                    self.waterIntake = water ?? 0
                    self.sleepMinutes = minutes ?? 0
                    self.stepCount = steps ?? 0
                    self.meditationDuration = meditation ?? 0
                    self.isLoading = false
                    self.syncDataToFirestore()
                }

            } catch {
                print("Error loading health data: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load health data: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func setupFirestoreListener() {
        removeListener()
        
        guard let userId = userId else { return }
        
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
            
            // Inside setupFirestoreListener()
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.dailyData = data
                    self.waterIntake = data["waterConsumption"] as? Int ?? self.waterIntake
                    self.sleepMinutes = data["sleepMinutes"] as? Int ?? self.sleepMinutes
                    self.stepCount = data["steps"] as? Int ?? self.stepCount
                }
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
            "sleepMinutes": sleepMinutes,  // Store as minutes
            "meditationDuration": meditationDuration,
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
            "sleepMinutes": sleepMinutes,  // Store as minutes
            "meditationDuration": meditationDuration,
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
                        meditationDuration: nil,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating water intake: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to update water intake: \(error.localizedDescription)" // Set error message
                }
            }
        }
    }
    
    // Updated method to work with minutes
    // In HealthDataViewModel.swift
    func updateSleepMinutes(_ minutes: Int) {
        self.sleepMinutes = minutes

        Task {
            do {
                if let userId = userId {
                    try await healthService.updateDailyHealthData(
                        for: userId,
                        date: Date(),
                        waterIntake: nil,
                        stepsTaken: nil,
                        sleepDuration: minutes,
                        meditationDuration: nil,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating sleep data: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to update sleep data: \(error.localizedDescription)"
                }
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
                        meditationDuration: nil,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating steps count: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to update steps count: \(error.localizedDescription)" // Set error message
                }
            }
        }
    }
    
    func updateMeditationDuration(_ duration: Int) {
        self.meditationDuration += duration
        
        Task {
            do {
                if let userId = userId {
                    let currentDuration = try await healthService.fetchTodaysMeditationData(for: userId, date: Date()) ?? 0
                    
                    try await healthService.updateDailyHealthData(
                        for: userId,
                        date: Date(),
                        waterIntake: nil,
                        stepsTaken: nil,
                        sleepDuration: nil,
                        meditationDuration: currentDuration + duration,
                        exerciseTime: nil
                    )
                    syncDataToFirestore()
                }
            } catch {
                print("Error updating meditation duration: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to update meditation duration: \(error.localizedDescription)" // Set error message
                }
            }
        }
    }
    
    func refreshData() {
        loadAllData()
    }
}

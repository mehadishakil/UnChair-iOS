//
//  HealthDataViewModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 17/3/25.
//

//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//import SwiftUI
//
//class HealthDataViewModel: ObservableObject {
//    @Published var waterIntake: Int = 0
//    @Published var sleepMinutes: Int = 0  // Changed from sleepHours to sleepMinutes
//    @Published var stepCount: Int = 0
//    @Published var meditationDuration: Int = 0
//    @Published var isLoading: Bool = true
//    @Published var dailyData: [String: Any] = [:]
//    @Published var errorMessage: String?
//    
//    let healthService = HealthDataService()
//    private let firestoreService = FirestoreService()
//    private var userId: String?
//    private var firestoreListener: ListenerRegistration?
//    private var today: String {
//        return DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
//    }
//    
//    init() {
//        if let currentUser = Auth.auth().currentUser {
//            setUserId(currentUser.uid)
//        }
//    }
//    
//    deinit {
//        removeListener()
//    }
//    
//    func setUserId(_ id: String) {
//        userId = id
//        setupFirestoreListener()
//        loadAllData()
//    }
//
//    func loadAllData() {
//        guard let userId = userId else { return }
//        isLoading = true
//        
//        Task {
//            do {
//                async let waterTask = try healthService.fetchTodaysWaterData(for: userId, date: Date())
//                async let sleepTask = try healthService.fetchTodaysSleepData(for: userId, date: Date())
//                async let stepsTask = try healthService.fetchTodaySteps()
//                async let meditationTask = try healthService.fetchTodaysMeditationData(for: userId, date: Date())
//
//                let (water, minutes, steps, meditation) = await try (waterTask, sleepTask, stepsTask, meditationTask)
//                await MainActor.run {
//                    self.waterIntake = water ?? 0
//                    self.sleepMinutes = minutes ?? 0
//                    self.stepCount = steps ?? 0
//                    self.meditationDuration = meditation ?? 0
//                    self.isLoading = false
//                    self.syncDataToFirestore()
//                }
//
//            } catch {
//                print("Error loading health data: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.isLoading = false
//                    self.errorMessage = "Failed to load health data: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    func setupFirestoreListener() {
//        removeListener()
//        
//        guard let userId = userId else { return }
//        
//        let userDoc = Firestore.firestore()
//            .collection("users")
//            .document(userId)
//            .collection("health_data")
//            .document(today)
//        
//        firestoreListener = userDoc.addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("Error listening for data: \(error.localizedDescription)")
//                return
//            }
//            
//            // Inside setupFirestoreListener()
//            if let data = snapshot?.data() {
//                DispatchQueue.main.async {
//                    self.dailyData = data
//                    self.waterIntake = data["waterConsumption"] as? Int ?? self.waterIntake
//                    self.sleepMinutes = data["sleepMinutes"] as? Int ?? self.sleepMinutes
//                    self.stepCount = data["steps"] as? Int ?? self.stepCount
//                }
//            }
//        }
//    }
//    
//    private func removeListener() {
//        firestoreListener?.remove()
//        firestoreListener = nil
//    }
//    
//    private func createInitialDocument() {
//        guard let userId = userId else { return }
//        
//        let initialData: [String: Any] = [
//            "steps": stepCount,
//            "waterConsumption": waterIntake,
//            "sleepMinutes": sleepMinutes,  // Store as minutes
//            "meditationDuration": meditationDuration,
//            "activities": [],
//            "lastUpdated": Date()
//        ]
//        
//        firestoreService.createDocument(for: today, initialData: initialData) { error in
//            if let error = error {
//                print("Error creating document: \(error.localizedDescription)")
//            } else {
//                print("Initial document created successfully")
//                self.dailyData = initialData
//            }
//        }
//    }
//
//    private func syncDataToFirestore() {
//        guard let userId = userId else { return }
//        
//        let updatedData: [String: Any] = [
//            "steps": stepCount,
//            "waterConsumption": waterIntake,
//            "sleepMinutes": sleepMinutes,  // Store as minutes
//            "meditationDuration": meditationDuration,
//            "lastUpdated": Date()
//        ]
//        
//        firestoreService.syncData(for: today, updatedData: updatedData) { error in
//            if let error = error {
//                print("Error syncing data: \(error.localizedDescription)")
//            } else {
//                print("Data synced successfully!")
//            }
//        }
//    }
//    
//    // MARK: - Update Methods
//    
//    func updateWaterIntake(_ amount: Int) {
//        self.waterIntake = amount
//        
//        Task {
//            do {
//                if let userId = userId {
//                    try await healthService.updateDailyHealthData(
//                        for: userId,
//                        date: Date(),
//                        waterIntake: amount,
//                        stepsTaken: nil,
//                        sleepDuration: nil,
//                        meditationDuration: nil,
//                        exerciseTime: nil
//                    )
//                    syncDataToFirestore()
//                }
//            } catch {
//                print("Error updating water intake: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.errorMessage = "Failed to update water intake: \(error.localizedDescription)" // Set error message
//                }
//            }
//        }
//    }
//    
//    // Updated method to work with minutes
//    // In HealthDataViewModel.swift
//    func updateSleepMinutes(_ minutes: Int) {
//        self.sleepMinutes = minutes
//
//        Task {
//            do {
//                if let userId = userId {
//                    try await healthService.updateDailyHealthData(
//                        for: userId,
//                        date: Date(),
//                        waterIntake: nil,
//                        stepsTaken: nil,
//                        sleepDuration: minutes,
//                        meditationDuration: nil,
//                        exerciseTime: nil
//                    )
//                    syncDataToFirestore()
//                }
//            } catch {
//                print("Error updating sleep data: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.errorMessage = "Failed to update sleep data: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    func updateStepCount(_ steps: Int) {
//        self.stepCount = steps
//        
//        Task {
//            do {
//                if let userId = userId {
//                    try await healthService.updateDailyHealthData(
//                        for: userId,
//                        date: Date(),
//                        waterIntake: nil,
//                        stepsTaken: steps,
//                        sleepDuration: nil,
//                        meditationDuration: nil,
//                        exerciseTime: nil
//                    )
//                    syncDataToFirestore()
//                }
//            } catch {
//                print("Error updating steps count: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.errorMessage = "Failed to update steps count: \(error.localizedDescription)" // Set error message
//                }
//            }
//        }
//    }
//    
//    func updateMeditationDuration(_ duration: Int) {
//        self.meditationDuration += duration
//        
//        Task {
//            do {
//                if let userId = userId {
//                    let currentDuration = try await healthService.fetchTodaysMeditationData(for: userId, date: Date()) ?? 0
//                    
//                    try await healthService.updateDailyHealthData(
//                        for: userId,
//                        date: Date(),
//                        waterIntake: nil,
//                        stepsTaken: nil,
//                        sleepDuration: nil,
//                        meditationDuration: currentDuration + duration,
//                        exerciseTime: nil
//                    )
//                    syncDataToFirestore()
//                }
//            } catch {
//                print("Error updating meditation duration: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.errorMessage = "Failed to update meditation duration: \(error.localizedDescription)" // Set error message
//                }
//            }
//        }
//    }
//    
//    func refreshData() {
//        loadAllData()
//    }
//}

//
//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//import SwiftUI
//
//class HealthDataViewModel: ObservableObject {
//    // Persisted daily metrics
//    @Published var waterIntake: Int = UserDefaults.standard.integer(forKey: "dailyWaterIntake") {
//        didSet { UserDefaults.standard.set (waterIntake, forKey: "dailyWaterIntake") }
//    }
//    @Published var sleepMinutes: Int = UserDefaults.standard.integer(forKey: "dailySleepMinutes") {
//        didSet { UserDefaults.standard.set(sleepMinutes, forKey: "dailySleepMinutes") }
//    }
//    @Published var stepCount: Int = UserDefaults.standard.integer(forKey: "dailyStepCount") {
//        didSet { UserDefaults.standard.set(stepCount, forKey: "dailyStepCount") }
//    }
//    @Published var meditationDuration: Int = UserDefaults.standard.integer(forKey: "dailyMeditationDuration") {
//        didSet { UserDefaults.standard.set(meditationDuration, forKey: "dailyMeditationDuration") }
//    }
//    @Published var exerciseTime: [String:Int] = [:]
//    @Published var isLoading: Bool = true
//    @Published var dailyData: [String: Any] = [:]
//    @Published var errorMessage: String?
//    let healthService = HealthDataService()
//    private var authListener: AuthStateDidChangeListenerHandle?
//    private let firestoreService = FirestoreService()
//    private var userId: String?
//    private var firestoreListener: ListenerRegistration?
//    private var todayKey: String {
//      let formatter = DateFormatter()
//      formatter.dateFormat = "yyyy_MM_dd"
//      return "daily_log_\(formatter.string(from: Date()))"
//    }
//
//
//
//    init() {
//        // 1) Listen for user changes
//        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
//          guard let self = self else { return }
//          if let user = user {
//            self.setUserId(user.uid)
//          } else {
//            self.removeListener()
//            self.isLoading = false
//          }
//        }
//      }
//
//      deinit {
//        // clean up both listeners
//        if let handle = authListener {
//          Auth.auth().removeStateDidChangeListener(handle)
//        }
//        removeListener()
//      }
//
//    func setUserId(_ id: String) {
//        userId = id
//        setupFirestoreListener()
//        loadAllData()
//    }
//
//    /// Loads both local and remote data
//    func loadAllData() {
//        guard let userId = userId else { isLoading = false; return }
//        isLoading = true
//        Task {
//            do {
//                async let waterTask = try healthService.fetchTodaysWaterData(for: userId, date: Date())
//                async let sleepTask = try healthService.fetchTodaysSleepData(for: userId, date: Date())
//                async let stepsTask = try healthService.fetchTodaySteps()
//                async let meditationTask = try healthService.fetchTodaysMeditationData(for: userId, date: Date())
//
//                let (water, minutes, steps, meditation) = await try (waterTask, sleepTask, stepsTask, meditationTask)
//
//                await MainActor.run {
//                    if let w = water     { self.waterIntake = w }
//                    if let m = minutes   { self.sleepMinutes = m }
//                    self.stepCount = steps
//                    if let med = meditation { self.meditationDuration = med }
//                    self.isLoading = false
//                }
//            } catch {
//                print("Error loading health data: \(error.localizedDescription)")
//                await MainActor.run {
//                    self.isLoading = false
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    private func setupFirestoreListener() {
//        removeListener()
//        guard let userId = userId else { return }
//
//        let userDoc = Firestore.firestore()
//            .collection("users")
//            .document(userId)
//            .collection("health_data")
//            .document(todayKey)
//
//        firestoreListener = userDoc.addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Snapshot listener error: \(error.localizedDescription)")
//                return
//            }
//            if let snapshot = snapshot {
//                if !snapshot.exists {
//                    // Create document if it doesn't exist
//                    self.createInitialDocument()
//                }
//                if let data = snapshot.data() {
//                    DispatchQueue.main.async {
//                        if let w = data["waterIntake"] as? Int     { self.waterIntake = w }
//                        if let s = data["sleepDuration"] as? Int         { self.sleepMinutes = s }
//                        if let st = data["stepsTaken"] as? Int               { self.stepCount = st }
//                        if let med = data["meditationDuration"] as? Int { self.meditationDuration = med }
//                        if let et = data["exerciseTime"] as? [String:Int] { self.exerciseTime    = et }
//                    }
//                }
//            }
//        }
//    }
//
//    private func removeListener() {
//        firestoreListener?.remove()
//        firestoreListener = nil
//    }
//
//    /// Creates the initial document for today's health data
//    private func createInitialDocument() {
//        guard let userId = userId else { return }
//        let initialData: [String: Any] = [
//            "waterIntake": waterIntake,
//            "sleepDuration": sleepMinutes,
//            "stepsTaken": stepCount,
//            "meditationDuration": meditationDuration,
//            "exerciseTime": exerciseTime,
//            "lastUpdated": Date()
//        ]
//        firestoreService.createDocument(for: todayKey, initialData: initialData) { error in
//            if let error = error {
//                print("Error creating initial document: \(error.localizedDescription)")
//            } else {
//                print("Initial document created for \(self.todayKey)")
//            }
//        }
//    }
//
//    // MARK: - Update Methods
//
//    func updateWaterIntake(_ amount: Int) {
//        waterIntake = amount
//        performUpdate(
//            waterIntake: amount,
//            stepsTaken: nil,
//            sleepDuration: nil,
//            meditationDuration: nil,
//            exerciseTime: nil
//        )
//    }
//
//    func updateSleepMinutes(_ minutes: Int) {
//        sleepMinutes = minutes
//        performUpdate(
//            waterIntake: nil,
//            stepsTaken: nil,
//            sleepDuration: minutes,
//            meditationDuration: nil,
//            exerciseTime: nil
//        )
//    }
//
//    func updateStepCount(_ steps: Int) {
//        stepCount = steps
//        performUpdate(
//            waterIntake: nil,
//            stepsTaken: steps,
//            sleepDuration: nil,
//            meditationDuration: nil,
//            exerciseTime: nil
//        )
//    }
//
//    func updateMeditationDuration(_ duration: Int) {
//        meditationDuration = duration
//        performUpdate(
//            waterIntake: nil,
//            stepsTaken: nil,
//            sleepDuration: nil,
//            meditationDuration: duration,
//            exerciseTime: nil
//        )
//    }
//
//    private func performUpdate(
//        waterIntake: Int?,
//        stepsTaken: Int?,
//        sleepDuration: Int?,
//        meditationDuration: Int?,
//        exerciseTime: [String: Int]?
//    ) {
//        guard let userId = userId else { return }
//        Task {
//            do {
//                try await healthService.updateDailyHealthData(
//                    for: userId,
//                    date: Date(),
//                    waterIntake: waterIntake,
//                    stepsTaken: stepsTaken,
//                    sleepDuration: sleepDuration,
//                    meditationDuration: meditationDuration,
//                    exerciseTime: exerciseTime
//                )
//                syncDataToFirestore()
//            } catch {
//                print("Error updating data: \(error.localizedDescription)")
//                await MainActor.run { self.errorMessage = error.localizedDescription }
//            }
//        }
//    }
//
//    private func syncDataToFirestore() {
//        guard let userId = userId else { return }
//        let updatedData: [String: Any] = [
//            "waterIntake": waterIntake,
//            "sleepDuration": sleepMinutes,
//            "stepsTaken": stepCount,
//            "meditationDuration": meditationDuration,
//            "exerciseTime" : exerciseTime,
//            "lastUpdated": Date()
//        ]
//        firestoreService.syncData(for: todayKey, updatedData: updatedData) { error in
//            if let e = error { print("Firestore sync error: \(e.localizedDescription)") }
//        }
//    }
//
//    /// Manually refresh both local and remote data
//    func refreshData() {
//        loadAllData()
//    }
//}


import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class HealthDataViewModel: ObservableObject {
    @Published var waterIntake: Int = 0
    @Published var sleepDuration: Int = 0
    @Published var stepCount: Int = 0
    @Published var meditationDuration: Int = 0
    @Published var exerciseTime: [String:Int] = [:]
    @Published var isLoading: Bool = true
    @Published var dailyData: [String: Any] = [:]
    @Published var errorMessage: String?
    @Published var historicalData: [String: [String: Any]] = [:]
    
    let healthService = HealthDataService()
    private var authListener: AuthStateDidChangeListenerHandle?
    private let firestoreService = FirestoreService()
    private var userId: String?
    private var firestoreListener: ListenerRegistration?
    
    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        return "daily_log_\(formatter.string(from: Date()))"
    }

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.setUserId(user.uid)
            } else {
                self.removeListener()
                self.isLoading = false
            }
        }
    }

    deinit {
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        removeListener()
    }

    func setUserId(_ id: String) {
        userId = id
        setupFirestoreListener()
        loadAllData()
    }

    /// Loads both local and remote data, including historical data
    func loadAllData() {
        guard let userId = userId else { return }
        isLoading = true
        
        // First try to load from Firestore
        fetchFirestoreData { [weak self] in
            guard let self = self else { return }
            
            // Then try to fetch from HealthKit if needed
            Task {
                do {
                    // Only fetch from HealthKit if we don't have local data
                    if self.waterIntake == 0 {
                        if let water = try await self.healthService.fetchTodaysWaterData(for: userId, date: Date()) {
                            await MainActor.run { self.waterIntake = water }
                        }
                    }
                    
                    if self.sleepDuration == 0 {
                        if let sleep = try await self.healthService.fetchTodaysSleepData(for: userId, date: Date()) {
                            await MainActor.run { self.sleepDuration = sleep }
                        }
                    }
                    
                    if self.stepCount == 0 {
                        let steps = try await self.healthService.fetchTodaySteps()
                        await MainActor.run { self.stepCount = steps }
                    }
                    
                    if self.meditationDuration == 0 {
                        if let meditation = try await self.healthService.fetchTodaysMeditationData(for: userId, date: Date()) {
                            await MainActor.run { self.meditationDuration = meditation }
                        }
                    }
                    
                    await MainActor.run {
                        self.isLoading = false
                        self.syncDataToFirestore() // Ensure all data is synced
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
    }
    
    private func fetchFirestoreData(completion: @escaping () -> Void) {
        guard let userId = userId else {
            isLoading = false
            completion()
            return
        }
        
        let docRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("health_data")
            .document(todayKey)
        
        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                self.isLoading = false
                completion()
                return
            }
            
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.dailyData = data
                    self.waterIntake = data["waterIntake"] as? Int ?? (data["waterConsumption"] as? Int ?? 0)
                    self.sleepDuration = data["sleepDuration"] as? Int ?? (data["sleepMinutes"] as? Int ?? 0)
                    self.stepCount = data["stepsTaken"] as? Int ?? (data["steps"] as? Int ?? 0)
                    self.meditationDuration = data["meditationDuration"] as? Int ?? 0
                    self.exerciseTime = data["exerciseTime"] as? [String: Int] ?? [:]
                    self.isLoading = false
                }
            } else {
                // No document exists yet
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            completion()
        }
    }
    
    func setupFirestoreListener() {
        removeListener()
        
        guard let userId = userId else { return }
        
        let userDoc = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("health_data")
            .document(todayKey)
        
        firestoreListener = userDoc.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for data: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.dailyData = data
                    // Update properties only if they're different to avoid unnecessary UI updates
                    if let water = data["waterIntake"] as? Int, self.waterIntake != water {
                        self.waterIntake = water
                    }
                    if let sleep = data["sleepDuration"] as? Int, self.sleepDuration != sleep {
                        self.sleepDuration = sleep
                    }
                    if let steps = data["stepsTaken"] as? Int, self.stepCount != steps {
                        self.stepCount = steps
                    }
                    if let meditation = data["meditationDuration"] as? Int, self.meditationDuration != meditation {
                        self.meditationDuration = meditation
                    }
                    if let exercise = data["exerciseTime"] as? [String: Int] {
                        self.exerciseTime = exercise
                    }
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
            "sleepDuration": sleepDuration,  // Store as minutes
            "meditationDuration": meditationDuration,
            "activities": [],
            "lastUpdated": Date()
        ]
        
        firestoreService.createDocument(for: todayKey, initialData: initialData) { error in
            if let error = error {
                print("Error creating document: \(error.localizedDescription)")
            } else {
                print("Initial document created successfully")
                self.dailyData = initialData
            }
        }
    }

    // MARK: - Update Methods (unchanged)
    func updateWaterIntake(_ amount: Int) {
        waterIntake = amount
        performUpdate(
            waterIntake: amount,
            stepsTaken: nil,
            sleepDuration: nil,
            meditationDuration: nil,
            exerciseTime: nil
        )
    }

    func updateSleepMinutes(_ minutes: Int) {
        sleepDuration = minutes
        performUpdate(
            waterIntake: nil,
            stepsTaken: nil,
            sleepDuration: minutes,
            meditationDuration: nil,
            exerciseTime: nil
        )
    }

    func updateStepCount(_ steps: Int) {
        stepCount = steps
        performUpdate(
            waterIntake: nil,
            stepsTaken: steps,
            sleepDuration: nil,
            meditationDuration: nil,
            exerciseTime: nil
        )
    }

    func updateMeditationDuration(_ duration: Int) {
        meditationDuration = duration
        performUpdate(
            waterIntake: nil,
            stepsTaken: nil,
            sleepDuration: nil,
            meditationDuration: duration,
            exerciseTime: nil
        )
    }

    private func performUpdate(
        waterIntake: Int?,
        stepsTaken: Int?,
        sleepDuration: Int?,
        meditationDuration: Int?,
        exerciseTime: [String: Int]?
    ) {
        guard let userId = userId else { return }
        Task {
            do {
                try await healthService.updateDailyHealthData(
                    for: userId,
                    date: Date(),
                    waterIntake: waterIntake,
                    stepsTaken: stepsTaken,
                    sleepDuration: sleepDuration,
                    meditationDuration: meditationDuration,
                    exerciseTime: exerciseTime
                )
                syncDataToFirestore()
            } catch {
                print("Error updating data: \(error.localizedDescription)")
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }

    private func syncDataToFirestore() {
        guard let userId = userId else { return }
        let updatedData: [String: Any] = [
            "waterIntake": waterIntake,
            "sleepDuration": sleepDuration,
            "stepsTaken": stepCount,
            "meditationDuration": meditationDuration,
            "exerciseTime": exerciseTime,
            "lastUpdated": Date()
        ]
        firestoreService.syncData(for: todayKey, updatedData: updatedData) { error in
            if let e = error { print("Firestore sync error: \(e.localizedDescription)") }
        }
    }

    /// Manually refresh both local and remote data
    func refreshData() {
        loadAllData()
    }
    
    /// Helper method to get historical data for display purposes
    func getHistoricalDataForDate(_ date: Date) -> [String: Any]? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let dateKey = "daily_log_\(formatter.string(from: date))"
        return historicalData[dateKey]
    }
}

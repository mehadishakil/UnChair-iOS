//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var tabBarVisible = true
    @State private var selectedDuration = TimeDuration(hours: 0, minutes: 1)
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @EnvironmentObject private var authController: AuthController
    @EnvironmentObject private var healthViewModel: HealthDataViewModel

    var body: some View {
        TabView {
            HomeScreen(selectedDuration: $selectedDuration)
                .tabItem { Image(systemName: "house") }
                .onAppear {
                    // Refresh data when returning to this tab
                    healthViewModel.refreshData()
                }
            
            AnalyticScreen()
                .tabItem { Image(systemName: "chart.bar.xaxis") }
            
            ProfileScreen(selectedDuration: $selectedDuration)
                .tabItem { Image(systemName: "person") }
        }
        .edgesIgnoringSafeArea(.all)
        .tint(.primary)
        .preferredColorScheme(userTheme.colorScheme)
        .onAppear {
            // Initial data load when ContentView appears
            if let userId = authController.currentUser?.uid {
                healthViewModel.setUserId(userId)
            }
        }
    }
}


//struct ContentView: View {
//    @State private var tabBarVisible = true
//    @State private var selectedDuration = TimeDuration(hours: 0, minutes: 1)
//    @AppStorage("userTheme") private var userTheme: Theme = .system
//    @StateObject private var firestoreService = FirestoreService()
//    @State private var today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
//    @EnvironmentObject var authController: AuthController
//    @State private var dailyData: [String: Any] = [:]
//    
//
//    var body: some View {
//            TabView {
//                HomeScreen(selectedDuration: $selectedDuration)
//                    .tabItem { Image(systemName: "house") }
//                AnalyticScreen()
//                    .tabItem { Image(systemName: "chart.bar.xaxis") }
//                ProfileScreen(selectedDuration: $selectedDuration)
//                    .tabItem { Image(systemName: "person") }
//            }
//            .edgesIgnoringSafeArea(.all)
//            .tint(.primary)
//            .preferredColorScheme(userTheme.colorScheme)
//            .task {
//                guard let user = Auth.auth().currentUser else {
//                    print("User is not authenticated. Skipping data load.")
//                    return
//                }
//                let userDoc = Firestore.firestore().collection("users").document(user.uid).collection("dailyData").document(today)
//                userDoc.addSnapshotListener { snapshot, error in
//                    if let error = error {
//                        print("Error listening for data: \(error.localizedDescription)")
//                        return
//                    }
//                    if let data = snapshot?.data() {
//                        // Make sure to update on the main thread
//                        DispatchQueue.main.async {
//                            self.dailyData = data
//                        }
//                    }
//                }
//            }
//
//        }
//    
//    // Load data for today
//    private func loadDataForToday() {
//        firestoreService.documentExists(for: today) { exists in
//            if exists {
//                firestoreService.fetchUserData { result in
//                    switch result {
//                    case .success(let data):
//                        if let todayData = data[today] as? [String: Any] {
//                            DispatchQueue.main.async {
//                                dailyData = todayData
//                            }
//                        }
//                    case .failure(let error):
//                        print("Error fetching data: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                createDataForToday()
//            }
//        }
//    }
//
//
//    
//    // Create a document for today if it doesn't exist
//    private func createDataForToday() {
//        let initialData: [String: Any] = [
//            "steps": 0,
//            "waterConsumption": 0,
//            "activities": [],
//            "sleep": 0
//        ]
//        firestoreService.createDocument(for: today, initialData: initialData) { error in
//            if let error = error {
//                print("Error creating document: \(error.localizedDescription)")
//            } else {
//                dailyData = initialData
//            }
//        }
//    }
//    
//    // Sync today's data with Firestore
//    private func syncTodayData() {
//        firestoreService.syncData(for: today, updatedData: dailyData) { error in
//            if let error = error {
//                print("Error syncing data: \(error.localizedDescription)")
//            } else {
//                print("Data synced successfully!")
//            }
//        }
//    }
//    
//}


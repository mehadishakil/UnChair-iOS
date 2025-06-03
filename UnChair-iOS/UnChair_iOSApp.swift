//
//  UnChair_iOSApp.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseFirestore

@main
struct UnChair_iOSApp: App {
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @StateObject private var authController = AuthController()
    @StateObject private var healthViewModel = HealthDataViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainView()
                    .environmentObject(authController)
                    .environmentObject(healthViewModel)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
                            NotificationManager.shared.scheduleNextBreakNotification()
                        }
                    }
            } else {
                OnBoarding()
                    .environmentObject(healthViewModel)
            }
        }
        .modelContainer(for: [UserData.self, WaterChartModel.self, StepsChartModel.self, SleepChartModel.self, ExerciseChartModel.self])
    }
}



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
                    .onAppear {
                        // Migrate data to App Group on launch
                        AppGroupStorage.shared.migrateFromStandardUserDefaults()

                        // Auto-start Live Activity if within active hours
                        if #available(iOS 16.1, *) {
                            LiveActivityManager.shared.checkAndAutoStart()
                        }
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            print("🔵 App became active")

                            NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
                            NotificationManager.shared.scheduleNextBreakNotification()

                            // Check and restore Live Activity state (including break mode)
                            if #available(iOS 16.1, *) {
                                // Small delay to ensure storage is ready
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    LiveActivityManager.shared.checkAndAutoStart()
                                }
                            }
                        } else if newPhase == .background {
                            print("🔵 App going to background")
                            // Sync data to App Group when going to background
                            AppGroupStorage.shared.migrateFromStandardUserDefaults()

                            // Also sync break state
                            let storage = AppGroupStorage.shared
                            print("🔵 Break state at background: isOnBreak=\(storage.isOnBreak), breakEndTime=\(storage.breakEndTime)")
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



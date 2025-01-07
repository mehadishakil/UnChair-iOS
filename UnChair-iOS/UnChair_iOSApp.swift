//
//  UnChair_iOSApp.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI
import UserNotifications

@main
struct UnChair_iOSApp: App {
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @StateObject private var authController = AuthController()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authController)
        }
        .modelContainer(for: [WaterChartModel.self, StepsChartModel.self, SleepChartModel.self, ExerciseChartModel.self])
    }
}




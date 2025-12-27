//
//  AppDelegate.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore
import UserNotifications
import RevenueCat
import FirebaseAuth
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // Background task identifier
    static let liveActivityRefreshTaskIdentifier = "com.IsrailAhmed.UnChair-iOS.refresh.liveactivity"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Secrets.apiKey)

        // Set notification delegate to handle notifications
        UNUserNotificationCenter.current().delegate = self

        // Register background tasks for Live Activity updates
        registerBackgroundTasks()

        // Schedule first background task
        scheduleBackgroundLiveActivityRefresh()

        return true
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📬 Notification received while app in foreground: \(notification.request.identifier)")

        // Check if this is the break end notification
        if notification.request.identifier == "breakEnd" {
            print("🔔 Break end notification received - updating Live Activity")
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.checkAndAutoStart()
            }
        }

        // Show the notification
        completionHandler([.banner, .sound])
    }

    /// Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📬 Notification tapped: \(response.notification.request.identifier)")

        // Check if this is the break end notification
        if response.notification.request.identifier == "breakEnd" {
            print("🔔 Break end notification tapped - updating Live Activity")
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.checkAndAutoStart()
            }
        }

        completionHandler()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Google Sign-In
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }

        return false
    }

    // Handle app becoming active (user returns to the app)
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 App became active")

        NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
        NotificationManager.shared.scheduleNextBreakNotification()

        // Check and update Live Activity if break has ended
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.checkAndAutoStart()
        }

        // Re-schedule background task when app becomes active
        scheduleBackgroundLiveActivityRefresh()
    }

    // MARK: - Background Tasks

    /// Register background task handlers
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppDelegate.liveActivityRefreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleLiveActivityRefresh(task: task as! BGAppRefreshTask)
        }

        print("✅ Background task registered: \(AppDelegate.liveActivityRefreshTaskIdentifier)")
    }

    /// Schedule background refresh for Live Activity updates
    func scheduleBackgroundLiveActivityRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.liveActivityRefreshTaskIdentifier)

        // OPTIMIZATION: Try to run more frequently (5 minutes)
        // iOS will decide when to actually run it based on system conditions
        // If there's an active break, schedule it to run around when break ends
        let storage = AppGroupStorage.shared
        var targetInterval: TimeInterval = 5 * 60 // Default: 5 minutes

        if storage.isOnBreak && storage.breakEndTime > 0 {
            let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
            let timeUntilBreakEnd = breakEnd.timeIntervalSinceNow

            if timeUntilBreakEnd > 0 && timeUntilBreakEnd < 30 * 60 { // Within next 30 min
                // Schedule to run shortly after break ends
                targetInterval = timeUntilBreakEnd + 10 // 10 seconds after break ends
                print("🎯 Scheduling background task for break end: \(Int(targetInterval))s from now")
            }
        }

        request.earliestBeginDate = Date(timeIntervalSinceNow: targetInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background Live Activity refresh scheduled for ~\(Int(targetInterval/60)) minutes")
        } catch {
            print("❌ Could not schedule background task: \(error.localizedDescription)")
        }
    }

    /// Handle background refresh task for Live Activity
    private func handleLiveActivityRefresh(task: BGAppRefreshTask) {
        print("🔄 Background task started: Live Activity refresh")

        // Schedule the next background refresh
        scheduleBackgroundLiveActivityRefresh()

        // Create an expiration handler
        task.expirationHandler = {
            print("⚠️ Background task expired before completion")
        }

        // Update Live Activity in background
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.updateFromBackground()
        }

        // Mark task as complete
        task.setTaskCompleted(success: true)
        print("✅ Background task completed: Live Activity updated")
    }
}

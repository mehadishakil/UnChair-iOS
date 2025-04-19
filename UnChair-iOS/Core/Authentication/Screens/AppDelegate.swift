
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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
        
        // Configure notification permissions
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                print("Notification permission granted")
                // Schedule break notifications when app launches
                NotificationManager.shared.scheduleNextBreakNotification()
            } else {
                print("Notification permission denied")
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Handle app becoming active (user returns to the app)
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reschedule notifications when app becomes active
        NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
        NotificationManager.shared.scheduleNextBreakNotification()
    }
}

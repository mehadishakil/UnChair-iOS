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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Secrets.apiKey)

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Google Sign-In
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        // Handle Firebase Email Link Sign-In
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
            // Post notification to handle email link in the app
            NotificationCenter.default.post(
                name: .emailLinkReceived,
                object: url.absoluteString
            )
            return true
        }
        
        return false
    }
    
    // Handle app becoming active (user returns to the app)
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
        NotificationManager.shared.scheduleNextBreakNotification()
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let emailLinkReceived = Notification.Name("emailLinkReceived")
}

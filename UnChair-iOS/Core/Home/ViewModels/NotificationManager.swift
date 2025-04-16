//
//  NotificationManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 15/4/25.
//

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()

    private init() { }

    // Request notification permission from the user.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    // Schedule a break notification.
    // - Parameter timeInterval: The interval (in seconds) after which the notification will trigger.
    // - Parameter focusedDuration: The user-specified duration of focused time (used in the message).
    func scheduleBreakNotification(after timeInterval: TimeInterval, focusedDuration: TimeDuration) {
        let content = UNMutableNotificationContent()
        content.title = "Time to take a break!"
        content.body = "You've been focused for \(focusedDuration.totalMinutes) minutes. Stand up and stretch!"
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break notification: \(error.localizedDescription)")
            } else {
                print("Break notification scheduled to trigger in \(timeInterval) seconds")
            }
        }
    }

    // Cancel all pending notifications. This is useful when the user changes preferences.
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications")
    }
}

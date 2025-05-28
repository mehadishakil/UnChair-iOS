//
//  NotificationManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 19/4/25.


import Foundation
import UserNotifications
import SwiftUI

// Notification names for internal app communication
extension Notification.Name {
    static let breakNotificationTapped = Notification.Name("BreakNotificationTapped")
    static let breakSettingsChanged = Notification.Name("BreakSettingsChanged")
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // Singleton instance
    static let shared = NotificationManager()
    
    // Notification identifiers and categories
    private let breakReminderIdentifier = "break_reminder"
    private let breakReminderCategory = "BREAK_REMINDER"
    private let takeBreakActionIdentifier = "TAKE_BREAK"
    
    // Keys for UserDefaults
    private let lastBreakTimeKey = "lastBreakTime"
    private let lastBreakDayKey = "lastBreakDay"
    private let lastBreakMonthKey = "lastBreakMonth"
    private let lastBreakYearKey = "lastBreakYear"
    private let appNotificationEnabledKey = "appNotificationEnabled" // NEW: App-level toggle
    
    private let settings = SettingsManager.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - App-level notification toggle
    var isAppNotificationEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: appNotificationEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appNotificationEnabledKey)
            // When the app-level setting changes, update notification scheduling
            if newValue {
                scheduleNextBreakNotification()
            } else {
                cancelPendingBreakNotifications()
            }
        }
    }
    
    private override init() {
        super.init()
        setupNotificationDelegate()
        setupNotificationCategories()
    }
    
    // Set this class as the notification delegate
    private func setupNotificationDelegate() {
        notificationCenter.delegate = self
    }
    
    // Configure notification categories and actions
    private func setupNotificationCategories() {
        let takeBreakAction = UNNotificationAction(
            identifier: takeBreakActionIdentifier,
            title: "I took a break",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: breakReminderCategory,
            actions: [takeBreakAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    // Request notification permissions
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Check if notifications should be scheduled
    private func shouldScheduleNotifications(completion: @escaping (Bool) -> Void) {
        // First check app-level toggle
        guard isAppNotificationEnabled else {
            completion(false)
            return
        }
        
        // Then check system permission
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // Handle when a notification is tapped or an action is selected
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        // Only handle our break reminder notifications
        if identifier == breakReminderIdentifier {
            if response.actionIdentifier == takeBreakActionIdentifier {
                // User tapped the "I took a break" action
                saveLastBreakTime()
                scheduleNextBreakNotification()
            } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                // User tapped the notification itself
                NotificationCenter.default.post(name: .breakNotificationTapped, object: nil)
            }
        }
        
        completionHandler()
    }
    
    // Handle when a notification is displayed while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even if app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Save the current time as the last break time
    func saveLastBreakTime() {
        let now = Date()
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastBreakTimeKey)
        
        // Store date components for day change detection
        let components = Calendar.current.dateComponents([.year, .month, .day], from: now)
        UserDefaults.standard.set(components.day, forKey: lastBreakDayKey)
        UserDefaults.standard.set(components.month, forKey: lastBreakMonthKey)
        UserDefaults.standard.set(components.year, forKey: lastBreakYearKey)
    }
    
    // Get the last break time, or nil if it should be reset
    func getLastBreakTime() -> Date? {
        // Check if we need to reset first
        if shouldResetLastBreakTime() {
            return nil
        }
        
        let lastBreakTimeInterval = UserDefaults.standard.double(forKey: lastBreakTimeKey)
        if lastBreakTimeInterval > 0 {
            return Date(timeIntervalSince1970: lastBreakTimeInterval)
        }
        return nil
    }
    
    // Check if the last break time should be reset (new day or new active period)
    private func shouldResetLastBreakTime() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        let lastBreakDay = UserDefaults.standard.integer(forKey: lastBreakDayKey)
        let lastBreakMonth = UserDefaults.standard.integer(forKey: lastBreakMonthKey)
        let lastBreakYear = UserDefaults.standard.integer(forKey: lastBreakYearKey)
        
        // If no stored break data, no need to reset
        if lastBreakDay == 0 || lastBreakMonth == 0 || lastBreakYear == 0 {
            return false
        }
        
        // If date has changed, we should reset
        if lastBreakDay != todayComponents.day ||
           lastBreakMonth != todayComponents.month ||
           lastBreakYear != todayComponents.year {
            return true
        }
        
        // Also check if we're in a new active period
        return isNewActivePeriod(now)
    }
    
    // Check if we're in a new active period since the last break
    private func isNewActivePeriod(_ now: Date) -> Bool {
        let lastBreakTimeInterval = UserDefaults.standard.double(forKey: lastBreakTimeKey)
        
        if lastBreakTimeInterval > 0 {
            let calendar = Calendar.current
            let lastBreakTime = Date(timeIntervalSince1970: lastBreakTimeInterval)
            
            // Get components for comparison
            let nowComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
            let lastBreakComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: lastBreakTime)
            
            // If dates are different, it's a new day
            if nowComps.year != lastBreakComps.year ||
               nowComps.month != lastBreakComps.month ||
               nowComps.day != lastBreakComps.day {
                return true
            }
            
            // Get end time and start time components
            let endTimeComps = calendar.dateComponents([.hour, .minute], from: settings.endTime)
            let startTimeComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
            
            // Convert to minutes for easier comparison
            let lastBreakTotalMinutes = (lastBreakComps.hour! * 60) + lastBreakComps.minute!
            let endTotalMinutes = (endTimeComps.hour! * 60) + endTimeComps.minute!
            let nowTotalMinutes = (nowComps.hour! * 60) + nowComps.minute!
            let startTotalMinutes = (startTimeComps.hour! * 60) + startTimeComps.minute!
            
            // Handle schedules that span midnight
            if startTotalMinutes > endTotalMinutes {
                // We've crossed the end time since the last break
                if (lastBreakTotalMinutes < endTotalMinutes && nowTotalMinutes >= startTotalMinutes) {
                    return true
                }
                // We've gone past midnight since the last break
                if (lastBreakTotalMinutes >= startTotalMinutes &&
                    ((nowTotalMinutes < startTotalMinutes && nowTotalMinutes >= endTotalMinutes) ||
                     (nowTotalMinutes >= startTotalMinutes && lastBreakComps.day != nowComps.day))) {
                    return true
                }
            } else {
                // Normal day schedule (start time before end time)
                if (lastBreakTotalMinutes <= endTotalMinutes && lastBreakTotalMinutes >= startTotalMinutes) &&
                   ((nowTotalMinutes >= startTotalMinutes && nowTotalMinutes <= endTotalMinutes &&
                     lastBreakComps.day != nowComps.day) ||
                    (nowTotalMinutes < startTotalMinutes || nowTotalMinutes > endTotalMinutes)) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // Reset last break time if needed
    func checkAndResetLastBreakTimeIfNeeded() {
        if shouldResetLastBreakTime() {
            UserDefaults.standard.removeObject(forKey: lastBreakTimeKey)
            UserDefaults.standard.removeObject(forKey: lastBreakDayKey)
            UserDefaults.standard.removeObject(forKey: lastBreakMonthKey)
            UserDefaults.standard.removeObject(forKey: lastBreakYearKey)
        }
    }
    
    // Cancel any pending break reminder notifications
    func cancelPendingBreakNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [breakReminderIdentifier])
    }
    
    // MARK: - Updated scheduling method with dual checks
    // Calculate and schedule the next break notification
    func scheduleNextBreakNotification() {
        // Check both app-level and system-level permissions
        shouldScheduleNotifications { [weak self] shouldSchedule in
            guard let self = self, shouldSchedule else {
                // Cancel any pending notifications if we shouldn't schedule
                self?.cancelPendingBreakNotifications()
                return
            }
            
            // First, cancel any existing break notifications
            self.cancelPendingBreakNotifications()
            
            // Get the current date and time
            let now = Date()
            
            // Check if we're within active hours
            if !self.isWithinActiveHours(now) {
                // Schedule for the next active period start
                self.scheduleForNextActivePeriodStart()
                return
            }
            
            // Get the last break time or use the active period start
            let lastBreakTime = self.getLastBreakTime() ?? self.getActiveHourStartForToday()
            
            // Calculate the focused interval in seconds
            let focusedInterval = TimeInterval(self.settings.breakDuration.totalMinutes * 60)
            
            // Calculate when the next break should be
            let proposedNextBreakTime = lastBreakTime.addingTimeInterval(focusedInterval)
            
            // Get today's active end time
            let todayEndTime = self.getActiveHourEndForToday()
            
            // The next break time should be the earlier of the proposed time or the end of active hours
            let nextBreakTime = min(proposedNextBreakTime, todayEndTime)
            
            // Only schedule if it's in the future and within today's active hours
            if nextBreakTime > now && nextBreakTime <= todayEndTime {
                self.scheduleNotification(for: nextBreakTime)
            }
        }
    }
    
    // Schedule a notification for the given date
    private func scheduleNotification(for date: Date) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to take a break!"
        content.body = "Stand up, stretch, or walk for a few minutes."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = breakReminderCategory
        
        // Create calendar components trigger for precise timing
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: breakReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling break notification: \(error.localizedDescription)")
            } else {
                print("Break notification scheduled for: \(date)")
            }
        }
    }
    
    // Check if the given date is within active hours
    private func isWithinActiveHours(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: date)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!
        
        let startComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        let endComps = calendar.dateComponents([.hour, .minute], from: settings.endTime)
        let startSecs = (startComps.hour! * 3600) + (startComps.minute! * 60)
        let endSecs = (endComps.hour! * 3600) + (endComps.minute! * 60)
        
        if startSecs <= endSecs {
            // No midnight wrap
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            // Wraps past midnight
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }
    
    // Get the start time for today's active hours
    private func getActiveHourStartForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = startTimeComponents.hour
        components.minute = startTimeComponents.minute
        
        return calendar.date(from: components) ?? now
    }
    
    // Get the end time for today's active hours
    private func getActiveHourEndForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.endTime)
        
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = endTimeComponents.hour
        components.minute = endTimeComponents.minute
        
        // If end time is earlier than start time, it means it's the next day
        if settings.endTime < settings.startTime {
            if let date = calendar.date(from: components) {
                return calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
        }
        
        return calendar.date(from: components) ?? now
    }
    
    // Schedule notification for the next active period start
    private func scheduleForNextActivePeriodStart() {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = startTimeComponents.hour
        components.minute = startTimeComponents.minute
        
        var nextStart = calendar.date(from: components) ?? now
        
        // If the start time has already passed today, schedule for tomorrow
        if nextStart <= now {
            nextStart = calendar.date(byAdding: .day, value: 1, to: nextStart) ?? now
        }
        
        scheduleNotification(for: nextStart)
    }
}

extension NotificationManager {
    // Check if a break notification is already scheduled
    func hasScheduledNotification() -> Bool {
        let group = DispatchGroup()
        group.enter()
        
        var hasNotification = false
        
        notificationCenter.getPendingNotificationRequests { requests in
            hasNotification = requests.contains { $0.identifier == self.breakReminderIdentifier }
            group.leave()
        }
        
        // Wait for the async call to complete
        _ = group.wait(timeout: .now() + 1.0)
        return hasNotification
    }
    
    // MARK: - Helper method to get current notification status
    func getNotificationStatus(completion: @escaping (Bool, Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let systemEnabled = settings.authorizationStatus == .authorized
                let appEnabled = self.isAppNotificationEnabled
                completion(systemEnabled, appEnabled)
            }
        }
    }
}

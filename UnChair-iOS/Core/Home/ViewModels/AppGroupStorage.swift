//
//  AppGroupStorage.swift
//  UnChair-iOS
//
//  Shared storage for communication between main app and widget extension
//

import Foundation

class AppGroupStorage {
    static let shared = AppGroupStorage()

    private let userDefaults: UserDefaults?
    private let suiteName = "group.IsrailAhmed.UnChair-iOS"

    private init() {
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    // MARK: - Break Tracking

    var lastBreakTime: Double {
        get {
            userDefaults?.double(forKey: "LastBreakTime") ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: "LastBreakTime")
            userDefaults?.synchronize()
        }
    }

    // MARK: - Break Interval Settings

    var breakIntervalMins: Int {
        get {
            userDefaults?.integer(forKey: "breakIntervalMins") ?? 60
        }
        set {
            userDefaults?.set(newValue, forKey: "breakIntervalMins")
            userDefaults?.synchronize()
        }
    }

    // MARK: - Active Hours Settings

    var workStartHour: Int {
        get {
            userDefaults?.integer(forKey: "workStartHour") ?? 9
        }
        set {
            userDefaults?.set(newValue, forKey: "workStartHour")
            userDefaults?.synchronize()
        }
    }

    var workStartMinute: Int {
        get {
            userDefaults?.integer(forKey: "workStartMinute") ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: "workStartMinute")
            userDefaults?.synchronize()
        }
    }

    var workEndHour: Int {
        get {
            userDefaults?.integer(forKey: "workEndHour") ?? 17
        }
        set {
            userDefaults?.set(newValue, forKey: "workEndHour")
            userDefaults?.synchronize()
        }
    }

    var workEndMinute: Int {
        get {
            userDefaults?.integer(forKey: "workEndMinute") ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: "workEndMinute")
            userDefaults?.synchronize()
        }
    }

    // MARK: - Notification Settings

    var isAppNotificationEnabled: Bool {
        get {
            userDefaults?.bool(forKey: "appNotificationEnabled") ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: "appNotificationEnabled")
            userDefaults?.synchronize()
        }
    }

    // MARK: - Helper Methods

    /// Synchronize data from standard UserDefaults to App Group storage
    func migrateFromStandardUserDefaults() {
        let standard = UserDefaults.standard

        // Migrate if not already migrated
        if userDefaults?.object(forKey: "migrated") == nil {
            // Copy all values
            if let value = standard.object(forKey: "LastBreakTime") as? Double {
                lastBreakTime = value
            }
            if let value = standard.object(forKey: "breakIntervalMins") as? Int {
                breakIntervalMins = value
            }
            if let value = standard.object(forKey: "workStartHour") as? Int {
                workStartHour = value
            }
            if let value = standard.object(forKey: "workStartMinute") as? Int {
                workStartMinute = value
            }
            if let value = standard.object(forKey: "workEndHour") as? Int {
                workEndHour = value
            }
            if let value = standard.object(forKey: "workEndMinute") as? Int {
                workEndMinute = value
            }
            if let value = standard.object(forKey: "appNotificationEnabled") as? Bool {
                isAppNotificationEnabled = value
            }

            // Mark as migrated
            userDefaults?.set(true, forKey: "migrated")
            userDefaults?.synchronize()
        }
    }

    /// Sync a specific key from standard UserDefaults to App Group
    func syncFromStandardUserDefaults(key: String, value: Any) {
        userDefaults?.set(value, forKey: key)
        userDefaults?.synchronize()
    }
}

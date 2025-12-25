//
//  LiveActivityManager.swift
//  UnChair-iOS
//
//  Manager for Live Activity lifecycle
//

import Foundation
import ActivityKit
import SwiftUI
import Combine

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var currentActivity: Activity<SedentaryActivityAttributes>?
    private var lastColorState: SedentaryActivityAttributes.ContentState.ColorState?

    private init() {}

    // MARK: - Activity Lifecycle

    /// End all existing activities (cleanup stale activities)
    func endAllActivities() {
        Task {
            let activities = Activity<SedentaryActivityAttributes>.activities
            print("🔵 Ending \(activities.count) existing activities")

            for activity in activities {
                await activity.end(
                    ActivityContent(
                        state: activity.content.state,
                        staleDate: Date()
                    ),
                    dismissalPolicy: .immediate
                )
            }

            await MainActor.run {
                currentActivity = nil
                lastColorState = nil
            }

            print("✅ Cleanup complete")
        }
    }

    /// Start a new Live Activity
    func startActivity() {
        print("🟢 LiveActivityManager: startActivity() called")
        print("🟢 Current date/time: \(Date())")

        // Check Live Activities permission
        let authInfo = ActivityAuthorizationInfo()
        print("🟢 Live Activities enabled: \(authInfo.areActivitiesEnabled)")

        // Don't start if already running
        guard currentActivity == nil || currentActivity?.activityState == .ended else {
            print("🟡 Live Activity already running, state: \(String(describing: currentActivity?.activityState))")
            return
        }

        // Check if within active hours
        let withinHours = isWithinActiveHours()
        let storage = AppGroupStorage.shared
        print("🟢 Active hours check: \(withinHours)")
        print("🟢 Work hours: \(storage.workStartHour):\(String(format: "%02d", storage.workStartMinute)) - \(storage.workEndHour):\(String(format: "%02d", storage.workEndMinute))")

        guard withinHours else {
            print("🔴 Not within active hours, not starting Live Activity")
            return
        }

        // Validate storage data
        print("🟢 Break interval: \(storage.breakIntervalMins) mins")
        print("🟢 Last break time: \(storage.lastBreakTime > 0 ? Date(timeIntervalSince1970: storage.lastBreakTime).description : "Never")")

        do {
            let breakIntervalMins = storage.breakIntervalMins
            let lastBreakTime = storage.lastBreakTime

            guard breakIntervalMins > 0 else {
                print("❌ Invalid break interval: \(breakIntervalMins)")
                return
            }

            // Calculate session start time
            let sessionStart: Date

            if lastBreakTime > 0 {
                // Use last break time if it exists and is today
                let lastBreakDate = Date(timeIntervalSince1970: lastBreakTime)
                let calendar = Calendar.current

                if calendar.isDateInToday(lastBreakDate) {
                    sessionStart = lastBreakDate
                    print("🟢 Using last break time from today: \(sessionStart)")
                } else {
                    // If last break was not today, use active hour start
                    sessionStart = getActiveHourStartForToday()
                    print("🟢 Last break was not today, using active hour start: \(sessionStart)")
                }
            } else {
                // No previous break, use active hour start
                sessionStart = getActiveHourStartForToday()
                print("🟢 No previous break, using active hour start: \(sessionStart)")
            }

            // Create attributes
            let attributes = SedentaryActivityAttributes(
                workStartTime: getActiveHourStartForToday(),
                workEndTime: getActiveHourEndForToday(),
                userName: "User"
            )

            // Create initial content state
            let initialState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: sessionStart,
                breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                isOnBreak: false
            )

            print("🟢 Initial state - Elapsed: \(initialState.formattedElapsedTime), Progress: \(initialState.formattedProgress)")

            // Create activity content
            let content = ActivityContent(
                state: initialState,
                staleDate: nil
            )

            // Request the activity
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            lastColorState = initialState.colorState
            print("✅ Live Activity started successfully!")
            print("✅ Activity ID: \(currentActivity?.id ?? "none")")
            print("✅ Activity state: \(String(describing: currentActivity?.activityState))")
            print("✅ Break interval: \(breakIntervalMins) mins")
            print("✅ Session start: \(sessionStart)")
            print("✅ Color state: \(initialState.colorState.statusText)")

        } catch let error as NSError {
            print("❌ Error starting Live Activity")
            print("❌ Error domain: \(error.domain)")
            print("❌ Error code: \(error.code)")
            print("❌ Error description: \(error.localizedDescription)")
            print("❌ Error userInfo: \(error.userInfo)")

            // Provide helpful error messages
            if error.domain == "ActivityKit" {
                switch error.code {
                case 1:
                    print("💡 Hint: Live Activities may not be enabled in Settings")
                case 2:
                    print("💡 Hint: Too many Live Activities may be active")
                default:
                    print("💡 Hint: Unknown ActivityKit error")
                }
            }
        } catch {
            print("❌ Unexpected error starting Live Activity: \(error)")
            print("❌ Error type: \(type(of: error))")
        }
    }

    /// Update the activity state (called when thresholds crossed)
    func updateActivityState() {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        Task {
            let storage = AppGroupStorage.shared
            let breakIntervalMins = storage.breakIntervalMins
            let lastBreakTime = storage.lastBreakTime

            // Determine session start time
            let sessionStart: Date
            if lastBreakTime > 0 {
                sessionStart = Date(timeIntervalSince1970: lastBreakTime)
            } else {
                sessionStart = getActiveHourStartForToday()
            }

            // Create new state
            let newState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: sessionStart,
                breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                isOnBreak: false
            )

            // Only update if color state changed
            if newState.colorState != lastColorState {
                await activity.update(
                    ActivityContent(
                        state: newState,
                        staleDate: nil
                    )
                )
                lastColorState = newState.colorState
                print("Live Activity updated - color state: \(newState.colorState)")
            }
        }
    }

    /// Handle when user takes a break
    func handleBreakTaken() {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        Task {
            let now = Date()
            let storage = AppGroupStorage.shared

            // Update last break time in storage
            storage.lastBreakTime = now.timeIntervalSince1970

            // Create new state with reset timer
            let newState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: now,  // Reset to now
                breakIntervalSeconds: TimeInterval(storage.breakIntervalMins * 60),
                isOnBreak: false
            )

            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: nil
                )
            )

            lastColorState = newState.colorState
            print("Live Activity reset after break")
        }
    }

    /// End the current Live Activity
    func endActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(
                ActivityContent(
                    state: activity.content.state,
                    staleDate: Date()
                ),
                dismissalPolicy: .immediate
            )

            await MainActor.run {
                currentActivity = nil
                lastColorState = nil
            }

            print("Live Activity ended")
        }
    }

    /// Check and auto-start activity if needed
    func checkAndAutoStart() {
        print("🔵 checkAndAutoStart() called")

        // Check if within active hours first
        guard isWithinActiveHours() else {
            print("🔴 Not within active hours, skipping auto-start")
            // End any existing activities if outside active hours
            if !Activity<SedentaryActivityAttributes>.activities.isEmpty {
                endAllActivities()
            }
            return
        }

        // Check current activities
        let existingActivities = Activity<SedentaryActivityAttributes>.activities
        print("🔵 Found \(existingActivities.count) existing activities")

        // If we have an active activity, check if it's the current one we're tracking
        if let tracked = currentActivity, tracked.activityState == .active {
            print("🟢 Already have active tracked activity, no action needed")
            return
        }

        // If there are other activities but we're not tracking them, clean up
        if !existingActivities.isEmpty && currentActivity == nil {
            print("🟡 Found untracked activities, cleaning up")
            endAllActivities()
            // Give cleanup time to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startActivity()
            }
            return
        }

        print("🟢 Conditions met, calling startActivity()")
        // Start activity
        startActivity()
    }

    /// Get status of all Live Activities (for debugging)
    func printAllActivitiesStatus() {
        print("📊 === Live Activities Status ===")

        // Check if Live Activities are enabled
        print("📊 ActivityAuthorizationInfo.areActivitiesEnabled: \(ActivityAuthorizationInfo().areActivitiesEnabled)")

        let activities = Activity<SedentaryActivityAttributes>.activities
        print("📊 Total activities count: \(activities.count)")

        for (index, activity) in activities.enumerated() {
            print("📊 Activity #\(index + 1):")
            print("   ID: \(activity.id)")
            print("   State: \(String(describing: activity.activityState))")
            print("   Push token: \(activity.pushToken?.map { String(format: "%02x", $0) }.joined() ?? "none")")
            print("   Content state: \(activity.content.state)")
            print("   Attributes: workStart=\(activity.attributes.workStartTime), workEnd=\(activity.attributes.workEndTime)")
        }

        if let current = currentActivity {
            print("📊 Current tracked activity:")
            print("   ID: \(current.id)")
            print("   State: \(String(describing: current.activityState))")
        } else {
            print("📊 No current activity tracked")
        }

        // Print current time context
        let now = Date()
        print("📊 Current time: \(now)")
        print("📊 Within active hours: \(isWithinActiveHours())")

        print("📊 ==============================")
    }

    /// Update activity based on elapsed time (check for threshold crossings)
    func checkAndUpdateForTimeElapsed(_ elapsedSeconds: Int) {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        let storage = AppGroupStorage.shared
        let breakIntervalSeconds = storage.breakIntervalMins * 60
        let progressPercentage = Double(elapsedSeconds) / Double(breakIntervalSeconds)

        // Determine current color state
        let currentColorState: SedentaryActivityAttributes.ContentState.ColorState
        if progressPercentage >= 1.0 {
            currentColorState = .red
        } else if progressPercentage >= 0.8 {
            currentColorState = .orange
        } else {
            currentColorState = .green
        }

        // Update if color state changed
        if currentColorState != lastColorState {
            updateActivityState()
        }
    }

    // MARK: - Helper Methods

    private func isWithinActiveHours() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let storage = AppGroupStorage.shared
        let startSecs = (storage.workStartHour * 3600) + (storage.workStartMinute * 60)
        let endSecs = (storage.workEndHour * 3600) + (storage.workEndMinute * 60)

        if startSecs <= endSecs {
            // No midnight wrap
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            // Wraps past midnight
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }

    private func getActiveHourStartForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        let storage = AppGroupStorage.shared

        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = storage.workStartHour
        components.minute = storage.workStartMinute

        return calendar.date(from: components) ?? now
    }

    private func getActiveHourEndForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        let storage = AppGroupStorage.shared

        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = storage.workEndHour
        components.minute = storage.workEndMinute

        let endDate = calendar.date(from: components) ?? now

        // Handle midnight wrap
        let startDate = getActiveHourStartForToday()
        if endDate <= startDate {
            // End time is next day
            return calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }

        return endDate
    }
}

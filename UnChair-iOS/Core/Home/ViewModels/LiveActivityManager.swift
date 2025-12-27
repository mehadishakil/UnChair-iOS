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
import UserNotifications
import BackgroundTasks
import WidgetKit

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    // Shared notification identifier for break end notifications
    private static let breakEndNotificationIdentifier = "breakEnd"

    @Published private(set) var currentActivity: Activity<SedentaryActivityAttributes>?
    private var updateTimer: Timer?

    private init() {
        // Start periodic update timer
        startPeriodicUpdates()
    }

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

        // Check if we're currently on a break
        let isOnBreak = storage.isOnBreak
        let breakEndTime = storage.breakEndTime
        print("🟢 Is on break: \(isOnBreak), breakEndTime: \(breakEndTime)")

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

            // Create attributes
            let attributes = SedentaryActivityAttributes(
                workStartTime: getActiveHourStartForToday(),
                workEndTime: getActiveHourEndForToday(),
                userName: "User"
            )

            // Check if we need to restore break state
            let initialState: SedentaryActivityAttributes.ContentState

            if isOnBreak && breakEndTime > 0 {
                let breakEnd = Date(timeIntervalSince1970: breakEndTime)
                let now = Date()

                // Check if break is still active
                if breakEnd > now {
                    // Restore break state
                    let breakDuration = breakEnd.timeIntervalSince(now)
                    initialState = SedentaryActivityAttributes.ContentState(
                        sessionStartTime: now,
                        breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                        isOnBreak: true,
                        breakDurationSeconds: breakDuration,
                        breakEndTime: breakEnd
                    )
                    print("🟢 Restoring break state - \(Int(breakDuration / 60)) minutes remaining")
                } else {
                    // Break has ended, start work mode
                    initialState = SedentaryActivityAttributes.ContentState(
                        sessionStartTime: getSessionStart(storage: storage),
                        breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                        isOnBreak: false
                    )
                    print("🟢 Break ended, starting work mode")
                }
            } else {
                // Normal work mode
                initialState = SedentaryActivityAttributes.ContentState(
                    sessionStartTime: getSessionStart(storage: storage),
                    breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                    isOnBreak: false
                )
                print("🟢 Starting work mode - Elapsed: \(initialState.formattedElapsedTime)")
            }

            // Set staleDate to work end time + 1 minute so iOS automatically removes Live Activity when work hours end
            let workEndTime = getActiveHourEndForToday()
            let staleDate = workEndTime.addingTimeInterval(60) // 1 minute after work ends

            // Create activity content
            let content = ActivityContent(
                state: initialState,
                staleDate: staleDate
            )

            // Request the activity
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )

            print("✅ Live Activity started successfully!")
            print("✅ StaleDate set to: \(staleDate) (work ends at \(workEndTime))")
            print("✅ Activity ID: \(currentActivity?.id ?? "none")")
            print("✅ Activity state: \(String(describing: currentActivity?.activityState))")
            print("✅ Mode: \(initialState.isOnBreak ? "BREAK" : "WORK")")

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

    private func getSessionStart(storage: AppGroupStorage) -> Date {
        let lastBreakTime = storage.lastBreakTime

        if lastBreakTime > 0 {
            let lastBreakDate = Date(timeIntervalSince1970: lastBreakTime)
            let calendar = Calendar.current

            if calendar.isDateInToday(lastBreakDate) {
                return lastBreakDate
            }
        }

        return getActiveHourStartForToday()
    }

    /// Update the activity state (called when thresholds crossed)
    func updateActivityState() {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        Task {
            let storage = AppGroupStorage.shared
            let breakIntervalMins = storage.breakIntervalMins

            // Check if on break
            let newState: SedentaryActivityAttributes.ContentState
            if storage.isOnBreak && storage.breakEndTime > 0 {
                // Break mode - create state with break info
                let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
                let now = Date()

                if breakEnd > now {
                    let remaining = breakEnd.timeIntervalSince(now)
                    let totalDuration = TimeInterval(storage.breakDurationMinutes * 60)

                    newState = SedentaryActivityAttributes.ContentState(
                        sessionStartTime: now,
                        breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                        isOnBreak: true,
                        breakDurationSeconds: totalDuration,
                        breakEndTime: breakEnd
                    )
                } else {
                    // Break ended, switch to work mode
                    newState = createWorkModeState(storage: storage, breakIntervalMins: breakIntervalMins)
                }
            } else {
                // Work mode
                newState = createWorkModeState(storage: storage, breakIntervalMins: breakIntervalMins)
            }

            // Update if needed (force update for now to ensure colors update)
            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: nil
                )
            )
            print("🔄 Live Activity updated - mode: \(newState.isOnBreak ? "BREAK" : "WORK")")
        }
    }

    private func createWorkModeState(storage: AppGroupStorage, breakIntervalMins: Int) -> SedentaryActivityAttributes.ContentState {
        let sessionStart: Date
        if storage.lastBreakTime > 0 {
            sessionStart = Date(timeIntervalSince1970: storage.lastBreakTime)
        } else {
            sessionStart = getActiveHourStartForToday()
        }

        return SedentaryActivityAttributes.ContentState(
            sessionStartTime: sessionStart,
            breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
            isOnBreak: false
        )
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

            print("Live Activity reset after break")
        }
    }

    /// Start a break with specified duration
    func startBreak(durationMinutes: Int) {
        print("🔵 LiveActivityManager.startBreak called - duration: \(durationMinutes)")
        print("🔵 currentActivity: \(String(describing: currentActivity?.id))")
        print("🔵 activityState: \(String(describing: currentActivity?.activityState))")

        // Prevent starting breaks outside work hours
        guard isWithinActiveHours() else {
            print("⚠️ Cannot start break outside work hours")
            return
        }

        guard let activity = currentActivity else {
            print("⚠️ No active Live Activity to start break")
            return
        }
        guard activity.activityState == .active else {
            print("⚠️ Live Activity not active, state: \(activity.activityState)")
            return
        }

        Task {
            let now = Date()
            let storage = AppGroupStorage.shared
            let breakDuration = TimeInterval(durationMinutes * 60)
            let breakEndTime = now.addingTimeInterval(breakDuration)

            print("🔵 Break start: now=\(now), endTime=\(breakEndTime)")

            // Update last break time in storage
            storage.lastBreakTime = now.timeIntervalSince1970

            // CRITICAL: Save break state to App Group storage for persistence
            storage.isOnBreak = true
            storage.breakEndTime = breakEndTime.timeIntervalSince1970
            storage.breakDurationMinutes = durationMinutes

            print("🔵 Saved break state to storage: isOnBreak=\(storage.isOnBreak), breakEndTime=\(storage.breakEndTime)")

            // Create new state for break mode
            let newState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: now,
                breakIntervalSeconds: TimeInterval(storage.breakIntervalMins * 60),
                isOnBreak: true,
                breakDurationSeconds: breakDuration,
                breakEndTime: breakEndTime
            )

            print("🔵 Updating Live Activity with isOnBreak=true, breakEndTime=\(breakEndTime)")

            // Set staleDate to the earlier of: break end time or work end time
            // This ensures Live Activity is removed when work hours end even if on break
            let workEndTime = getActiveHourEndForToday()
            let effectiveStaleDate = min(breakEndTime.addingTimeInterval(2), workEndTime.addingTimeInterval(60))

            // iOS will re-render the Live Activity when staleDate is reached
            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: effectiveStaleDate
                ),
                alertConfiguration: nil
            )

            print("✅ StaleDate set to: \(effectiveStaleDate)")

            print("✅ Live Activity updated to break mode - \(durationMinutes) minutes")
            print("✅ Break end time: \(breakEndTime)")

            // Schedule notification for when break ends
            scheduleBreakEndNotification(endTime: breakEndTime)

            // Start timer to check when break ends (only works when app is active)
            startBreakEndTimer(breakEndTime: breakEndTime)

            // Note: Background task scheduling is done from the main app (SedentaryTime.swift)
            // to avoid compilation issues with widget extension target
        }
    }

    /// End break and switch back to work mode
    func endBreak() {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        // Cancel the break end timer if it's still running
        breakEndTimer?.invalidate()
        breakEndTimer = nil

        // Cancel the break end notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [LiveActivityManager.breakEndNotificationIdentifier])

        // CRITICAL: Capture break end time BEFORE async Task to avoid race condition
        let storage = AppGroupStorage.shared
        let breakEndTimeStored = storage.breakEndTime
        let breakIntervalMins = storage.breakIntervalMins

        Task {
            let now = Date()

            // CRITICAL: Use the break end time as the session start time
            // This ensures the timer continues from when the break actually ended, not when endBreak() was called
            let sessionStart: Date
            if breakEndTimeStored > 0 {
                sessionStart = Date(timeIntervalSince1970: breakEndTimeStored)
                print("🔵 Using break end time as session start: \(sessionStart)")
            } else {
                // Fallback to now if break end time isn't available
                sessionStart = now
                print("⚠️ Break end time not available, using current time")
            }

            // Update last break time to the session start (when break actually ended)
            storage.lastBreakTime = sessionStart.timeIntervalSince1970

            // CRITICAL: Clear break state from App Group storage
            storage.isOnBreak = false
            storage.breakEndTime = 0
            storage.breakDurationMinutes = 0

            print("🔵 Cleared break state from storage")

            // Reload widget to show active mode
            WidgetCenter.shared.reloadAllTimelines()

            // Create new state for work mode
            let newState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: sessionStart,  // Use break end time, not now
                breakIntervalSeconds: TimeInterval(breakIntervalMins * 60),
                isOnBreak: false,
                breakDurationSeconds: 0,
                breakEndTime: nil
            )

            // Set staleDate to work end time so Live Activity is removed when work hours end
            let workEndTime = getActiveHourEndForToday()
            let staleDate = workEndTime.addingTimeInterval(60)

            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: staleDate
                )
            )

            print("✅ Live Activity switched to work mode, session start: \(sessionStart)")
            print("✅ StaleDate set to: \(staleDate)")
        }
    }

    /// Schedule notification for when break ends
    private func scheduleBreakEndNotification(endTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Break Time Over!"
        content.body = "Time to get back to work. Stay active!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive // Make it more prominent

        // Add userInfo to identify this notification
        content.userInfo = ["type": "breakEnd", "endTime": endTime.timeIntervalSince1970]

        // CRITICAL: Set this to try waking app in background
        // Note: This only works if Background Modes > Remote notifications is enabled
        content.categoryIdentifier = "BREAK_END_CATEGORY"

        let timeInterval = endTime.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("⚠️ Break end time is in the past, not scheduling notification")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: LiveActivityManager.breakEndNotificationIdentifier, content: content, trigger: trigger)

        // Cancel any existing break end notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [LiveActivityManager.breakEndNotificationIdentifier])

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling break end notification: \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.timeStyle = .medium
                print("✅ Break end notification scheduled for \(formatter.string(from: endTime)) (in \(Int(timeInterval)) seconds)")
            }
        }
    }

    /// Start timer to auto-switch to work mode when break ends
    private func startBreakEndTimer(breakEndTime: Date) {
        // Cancel any existing timer
        breakEndTimer?.invalidate()

        // Create timer to fire when break ends
        let timeInterval = breakEndTime.timeIntervalSinceNow
        guard timeInterval > 0 else {
            endBreak()
            return
        }

        breakEndTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.endBreak()
        }
    }

    private var breakEndTimer: Timer?

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
            }

            print("Live Activity ended")
        }
    }

    /// Check and auto-start activity if needed
    func checkAndAutoStart() {
        print("🔵 checkAndAutoStart() called")

        let storage = AppGroupStorage.shared
        let isOnBreak = storage.isOnBreak
        let breakEndTime = storage.breakEndTime

        print("🔵 Current break state: isOnBreak=\(isOnBreak), breakEndTime=\(breakEndTime)")

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
            print("🟢 Already have active tracked activity")

            // Check if we need to restore break state or end it if already finished
            if isOnBreak && breakEndTime > 0 {
                let breakEnd = Date(timeIntervalSince1970: breakEndTime)
                let now = Date()

                if breakEnd > now {
                    print("🟢 Break is active, restoring break state in existing activity")
                    let breakDuration = breakEnd.timeIntervalSince(now)

                    Task {
                        let newState = SedentaryActivityAttributes.ContentState(
                            sessionStartTime: now,
                            breakIntervalSeconds: TimeInterval(storage.breakIntervalMins * 60),
                            isOnBreak: true,
                            breakDurationSeconds: breakDuration,
                            breakEndTime: breakEnd
                        )

                        await tracked.update(ActivityContent(state: newState, staleDate: breakEnd.addingTimeInterval(1)))
                        print("✅ Break state restored in existing Live Activity")
                    }
                } else {
                    // Break has already ended, switch to work mode
                    print("🟡 Break already ended, switching to work mode")
                    endBreak()
                }
            }

            return
        }

        // If there are other activities but we're not tracking them, restore the reference
        if !existingActivities.isEmpty && currentActivity == nil {
            print("🟡 Found untracked activities, restoring reference")
            // Restore the reference to the existing activity instead of destroying it
            currentActivity = existingActivities.first
            print("✅ Restored currentActivity reference: \(currentActivity?.id ?? "none")")

            // Now check if we need to update the break state
            if isOnBreak && breakEndTime > 0 {
                let breakEnd = Date(timeIntervalSince1970: breakEndTime)
                let now = Date()

                if breakEnd > now {
                    print("🟢 Break is active in restored activity")
                    // Break is still active, update will happen in refreshOnAppBecameActive()
                } else {
                    // Break has ended, switch to work mode
                    print("🟡 Break already ended in restored activity, switching to work mode")
                    endBreak()
                }
            }

            return
        }

        print("🟢 Conditions met, calling startActivity()")
        // Start activity (will automatically restore break state if needed)
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

    /// Update activity based on elapsed time
    func checkAndUpdateForTimeElapsed(_ elapsedSeconds: Int) {
        // No longer needed since we don't have dynamic color changes
        // Live Activity will auto-update its timer display
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

    // MARK: - Periodic Updates

    /// Start periodic timer to update Live Activity colors when app is active
    /// Note: This timer will pause when app goes to background (iOS limitation)
    /// Live Activity will still show correct time via native timers, but colors won't update until app becomes active
    private func startPeriodicUpdates() {
        // Invalidate any existing timer
        updateTimer?.invalidate()

        // Create a timer that fires every 15 seconds when app is active
        // This provides more frequent color updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.periodicUpdate()
        }

        // Allow timer to run in common run loop modes
        if let timer = updateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }

        print("✅ Started periodic Live Activity updates (every 15s when app active)")
    }

    /// Perform periodic update of Live Activity state
    private func periodicUpdate() {
        guard let activity = currentActivity else { return }
        guard activity.activityState == .active else { return }

        // Check if we're still within work hours - if not, end the Live Activity
        guard isWithinActiveHours() else {
            print("🔴 Work hours ended - ending Live Activity")
            endActivity()
            return
        }

        let storage = AppGroupStorage.shared

        // Check if break has ended and we need to switch to work mode
        if storage.isOnBreak && storage.breakEndTime > 0 {
            let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
            let now = Date()

            if breakEnd <= now {
                print("🔄 Periodic update detected break has ended - switching to work mode")
                endBreak()
                return
            }

            // Break is still active, update state
            updateActivityState()
        }
    }

    /// Call this when app becomes active to immediately update Live Activity
    func refreshOnAppBecameActive() {
        print("📱 App became active - refreshing Live Activity state")

        // Check if we're outside work hours - if so, end the Live Activity
        guard isWithinActiveHours() else {
            print("🔴 App became active outside work hours - ending Live Activity")
            if currentActivity != nil {
                endActivity()
            }
            return
        }

        // Check if break has ended and switch to work mode
        let storage = AppGroupStorage.shared
        if storage.isOnBreak && storage.breakEndTime > 0 {
            let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
            let now = Date()

            if breakEnd <= now {
                print("🟡 App became active - break has ended, switching to work mode")
                endBreak()
                return
            }
        }

        periodicUpdate()
    }

    /// Update Live Activity from background task
    /// This is called by BGTaskScheduler when the app is not running
    func updateFromBackground() {
        print("🌙 Background task updating Live Activity")

        // Check if we're outside work hours - if so, end all activities
        guard isWithinActiveHours() else {
            print("🔴 Background update outside work hours - ending all Live Activities")
            endAllActivities()
            return
        }

        // Try to restore activity from system if we don't have it
        if currentActivity == nil {
            let existingActivities = Activity<SedentaryActivityAttributes>.activities
            if let existing = existingActivities.first {
                currentActivity = existing
                print("🌙 Restored activity from system: \(existing.id)")
            } else {
                print("🌙 No active Live Activity found")
                return
            }
        }

        guard let activity = currentActivity else {
            print("🌙 No current activity to update")
            return
        }
        guard activity.activityState == .active else {
            print("🌙 Activity not active: \(activity.activityState)")
            return
        }

        let storage = AppGroupStorage.shared

        Task {
            // Check if break has ended and switch to work mode
            if storage.isOnBreak && storage.breakEndTime > 0 {
                let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
                let now = Date()

                if breakEnd <= now {
                    print("🌙 Background update - break has ended, switching to work mode")
                    endBreak()
                    return
                }
            }

            // Update activity state to ensure break mode is synced
            if storage.isOnBreak {
                updateActivityState()
            }
            print("🌙 Background update completed")
        }
    }

    deinit {
        updateTimer?.invalidate()
    }
}

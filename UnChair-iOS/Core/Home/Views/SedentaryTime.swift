////
////  SedentaryTime.swift
////  UnChair-iOS
////
////  Created by Mehadi Hasan on 5/6/24.
////
//
//import SwiftUI
//import Foundation
//
//struct SedentaryTime: View {
//    @StateObject private var settings = SettingsManager.shared
//    @Binding var notificationPermissionGranted: Bool
//    @Binding var selectedDuration: TimeDuration
//    @State private var timeElapsed: Int = 0
//    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    let onTakeBreak: () -> Void
//    @AppStorage("userTheme") private var userTheme: Theme = .system
//    @Environment(\.colorScheme) private var colorScheme
//    
//    
//    
//    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void) {
//        self._notificationPermissionGranted = notificationPermissionGranted
//        self._selectedDuration = selectedDuration
//        self.onTakeBreak = onTakeBreak
//    }
//    
//    var body: some View {
//        ZStack {
//            HStack() {
//                Image(systemName: "hourglass.tophalf.filled")
//                    .resizable()
//                    .frame(width: 90)
//                    .foregroundColor(.primary.opacity(0.9))
//                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
//                    .padding(.leading)
//                
//                Spacer()
//                
//                VStack(alignment: .center) {
//                    Text("Sedentary Time")
//                        .font(.headline.weight(.regular))
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    Text("\(formattedTime(timeElapsed))")
//                        .font(.largeTitle.bold())
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    Button {
//                        onTakeBreak()
//                    } label: {
//                        Text("Unchair")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 16)
//                            .background(
//                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                    .fill(.blue)
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
//                            )
//                    }
//                    .buttonStyle(.plain)
//                    
//                    
//                }
//                Spacer()
//            }
//            .padding()
//            .onAppear {
//                NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
//                updateTimeElapsed()
//                
//                NotificationCenter.default.addObserver(
//                    forName: .breakNotificationTapped,
//                    object: nil,
//                    queue: .main
//                ) { _ in
//                    updateTimeElapsed()
//                }
//                
//                NotificationCenter.default.addObserver(
//                    forName: .breakSettingsChanged,
//                    object: nil,
//                    queue: .main
//                ) { _ in
//                    NotificationManager.shared.scheduleNextBreakNotification()
//                }
//            }
//            .onDisappear {
//                NotificationCenter.default.removeObserver(self)
//            }
//            .onReceive(timer) { _ in
//                updateTimeElapsed()
//            }
//            
//        }
//        .frame(height: 170)
//        .background(
//            userTheme == .system
//            ? (colorScheme == .light ? .white : .darkGray)
//                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
//        )
//        .cornerRadius(20, corners: .allCorners)
//        .shadow(color: userTheme == .dark ? Color.gray.opacity(0.5) : Color.black.opacity(0.15), radius: 8)
//    }
//    
//    private func updateTimeElapsed() {
//        let now = Date()
//        
//        if isWithinActiveHours(now) {
//            let lastBreakTime = NotificationManager.shared.getLastBreakTime() ?? getActiveHourStartForToday()
//            
//            let elapsed = Int(now.timeIntervalSince(lastBreakTime))
//            timeElapsed = max(elapsed, 0)
//            
//            if notificationPermissionGranted &&
//                timeElapsed >= (selectedDuration.totalMinutes * 60) &&
//                !NotificationManager.shared.hasScheduledNotification() {
//                NotificationManager.shared.scheduleNextBreakNotification()
//            }
//        } else {
//            timeElapsed = 0
//        }
//    }
//    
//    private func isWithinActiveHours(_ date: Date) -> Bool {
//        let calendar = Calendar.current
//        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: date)
//        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!
//        
//        // Get start/end times for today
//        let startComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
//        let endComps = calendar.dateComponents([.hour, .minute], from: settings.endTime)
//        let startSecs = (startComps.hour! * 3600) + (startComps.minute! * 60)
//        let endSecs = (endComps.hour! * 3600) + (endComps.minute! * 60)
//        
//        if startSecs <= endSecs {
//            // No midnight wrap
//            return currentSecs >= startSecs && currentSecs <= endSecs
//        } else {
//            // Wraps past midnight
//            return currentSecs >= startSecs || currentSecs <= endSecs
//        }
//    }
//    
//    private func getActiveHourStartForToday() -> Date {
//        let calendar = Calendar.current
//        let now = Date()
//        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
//        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.startTime)
//        
//        // Combine today's date with start time
//        var components = DateComponents()
//        components.year = todayComponents.year
//        components.month = todayComponents.month
//        components.day = todayComponents.day
//        components.hour = startTimeComponents.hour
//        components.minute = startTimeComponents.minute
//        
//        return calendar.date(from: components) ?? now
//    }
//}
//
//func formattedTime(_ totalSeconds: Int) -> String {
//    let hours = (totalSeconds / 3600) % 24
//    let min = (totalSeconds % 3600) / 60
//    let sec = totalSeconds % 60
//    return String(format: "%02d:%02d:%02d", hours, min, sec)
//}
//
//#Preview {
//    SedentaryTime(notificationPermissionGranted: .constant(true), selectedDuration: .constant(.init(hours: 2, minutes: 2))) {
//        
//    }
//}

//
//  SedentaryTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/24.
//  Updated by ChatGPT to use AppStorage for active hours and handle wrap-around past midnight

import SwiftUI
import Foundation
import WidgetKit
import UIKit

struct SedentaryTime: View {
    @Binding var notificationPermissionGranted: Bool
    @Binding var selectedDuration: TimeDuration
    @State private var timeElapsed: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let onTakeBreak: () -> Void

    // Break mode state
    @State private var isOnBreak: Bool = false
    @State private var breakEndTime: Date?
    @State private var breakTimeRemaining: Int = 0
    @State private var showCancelBreakAlert: Bool = false
    @State private var breakDurationMinutes: Int = 0  // Store break duration for color calculation

    // Active hours from AppStorage
    @AppStorage("workStartHour") private var workStartHour: Int = 9
    @AppStorage("workStartMinute") private var workStartMinute: Int = 0
    @AppStorage("workEndHour") private var workEndHour: Int = 17
    @AppStorage("workEndMinute") private var workEndMinute: Int = 0
    @AppStorage("LastBreakTime") private var lastBreakTime: Double = 0
    @AppStorage("breakIntervalMins") private var breakIntervalMins: Int = 60  // Focus time from settings

    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme

    // Track if we're within work hours
    @State private var isWithinWorkHours: Bool = true

    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void) {
        self._notificationPermissionGranted = notificationPermissionGranted
        self._selectedDuration = selectedDuration
        self.onTakeBreak = onTakeBreak
    }

    // Simple color scheme: Orange for break time, Black for active time
    private var breakColor: Color {
        return .orange
    }

    private var activeTimeColor: Color {
        return .primary  // Black in light mode, white in dark mode
    }

    var body: some View {
        ZStack {
            if isOnBreak {
                // Break Mode UI
                HStack {
                    Image(systemName: "hourglass.tophalf.filled")
                        .resizable()
                        .frame(width: 90)
                        .foregroundColor(breakColor.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.leading)

                    Spacer()

                    VStack {
                        Text("Break Time")
                            .font(.headline)
                            .foregroundColor(breakColor)

                        Spacer()

                        Text(formattedTime(breakTimeRemaining))
                            .font(.largeTitle.bold())
                            .foregroundColor(breakColor)

                        Spacer()

                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(breakColor.opacity(0.8))
                            Text("Enjoy your break!")
                                .font(.subheadline)
                                .foregroundColor(breakColor)
                        }
                    }

                    Spacer()
                }
                .padding()
                .onTapGesture {
                    showCancelBreakAlert = true
                }
                .rotation3DEffect(
                    .degrees(isOnBreak ? 0 : 180),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    perspective: 0.5
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale),
                    removal: .opacity.combined(with: .scale)
                ))
            } else {
                // Work Mode UI (Original)
                HStack {
                    Image(systemName: "hourglass.tophalf.filled")
                        .resizable()
                        .frame(width: 90)
                        .foregroundColor(activeTimeColor.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.leading)

                    Spacer()

                    VStack {
                        Text("Sedentary Time")
                            .font(.headline)
                            .foregroundColor(activeTimeColor)

                        Spacer()

                        // Show 00:00:00 when outside work hours
                        Text(isWithinWorkHours ? formattedTime(timeElapsed) : "00:00:00")
                            .font(.largeTitle.bold())
                            .foregroundColor(activeTimeColor)

                        Spacer()

                        HStack(spacing: 8) {
                            // Unchair button with break duration menu - disabled outside work hours
                            Menu {
                                Button("1 minutes") {
                                    startBreak(duration: 1)
                                }
                                Button("5 minutes") {
                                    startBreak(duration: 5)
                                }
                                Button("10 minutes") {
                                    startBreak(duration: 10)
                                }
                                Button("20 minutes") {
                                    startBreak(duration: 20)
                                }
                            } label: {
                                Text("Unchair")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(isWithinWorkHours ? Color.primary : Color.gray))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            .disabled(!isWithinWorkHours)
                            .buttonStyle(.plain)

                        // Debug: Start/Stop Live Activity
                        if #available(iOS 16.1, *) {
                            Menu {
                                Button("Reset & Start Fresh") {
                                    // Reset break time to now
                                    let now = Date()
                                    lastBreakTime = now.timeIntervalSince1970
                                    AppGroupStorage.shared.lastBreakTime = now.timeIntervalSince1970

                                    // Reload widget to reflect new time
                                    WidgetCenter.shared.reloadAllTimelines()

                                    // Clean up and start fresh
                                    LiveActivityManager.shared.endAllActivities()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        LiveActivityManager.shared.startActivity()
                                    }
                                }
                                Button("Start Live Activity") {
                                    LiveActivityManager.shared.startActivity()
                                }
                                Button("End Live Activity") {
                                    LiveActivityManager.shared.endActivity()
                                }
                                Button("Clean Up All") {
                                    LiveActivityManager.shared.endAllActivities()
                                }
                                Button("Print Status") {
                                    LiveActivityManager.shared.printAllActivitiesStatus()
                                }
                            } label: {
                                Image(systemName: "bolt.circle")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .rotation3DEffect(
                .degrees(isOnBreak ? 180 : 0),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: 0.5
            )
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale),
                removal: .opacity.combined(with: .scale)
            ))
            }
        }
        .frame(height: 170)
        .background(
            userTheme == .system
            ? (colorScheme == .light ? Color.white : Color(.darkGray))
                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        )
        .cornerRadius(20)
        .shadow(color: userTheme == .dark ? Color.gray.opacity(0.5) : Color.black.opacity(0.15), radius: 8)
        .alert("Cancel Break?", isPresented: $showCancelBreakAlert) {
            Button("Cancel Break", role: .destructive) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    cancelBreak()
                }
            }
            Button("Continue Break", role: .cancel) { }
        } message: {
            Text("Are you sure you want to end your break early?")
        }
        .onAppear {
            // Restore break state if app was closed during break
            restoreBreakStateIfNeeded()

            updateTimeElapsed()
            NotificationCenter.default.addObserver(forName: .breakNotificationTapped, object: nil, queue: .main) { _ in
                updateTimeElapsed()
            }
            NotificationCenter.default.addObserver(forName: .breakSettingsChanged, object: nil, queue: .main) { _ in
                NotificationManager.shared.scheduleNextBreakNotification()
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .onReceive(timer) { _ in
            // Check if we're still within work hours
            let withinHours = checkIsWithinWorkHours()
            isWithinWorkHours = withinHours

            // If we go outside work hours while on break, end the break
            if !withinHours && isOnBreak {
                print("⚠️ Work hours ended during break, ending break")
                endBreak()
                return
            }

            if isOnBreak {
                updateBreakTime()
            } else {
                updateTimeElapsed()
            }
        }
    }

    private func startBreak(duration: Int) {
        // DON'T call onTakeBreak() to avoid scrolling to exercise section

        // Prevent starting breaks outside work hours
        guard checkIsWithinWorkHours() else {
            print("⚠️ Cannot start break outside work hours")
            return
        }

        // Calculate break end time
        let endTime = Date().addingTimeInterval(TimeInterval(duration * 60))

        // Persist break state to App Group storage
        let storage = AppGroupStorage.shared
        storage.isOnBreak = true
        storage.breakEndTime = endTime.timeIntervalSince1970
        storage.breakDurationMinutes = duration

        print("🔵 startBreak called - duration: \(duration) min, endTime: \(endTime)")

        // Reload widget to show break mode
        WidgetCenter.shared.reloadAllTimelines()

        // Ensure Live Activity is running before switching to break mode
        if #available(iOS 16.1, *) {
            let manager = LiveActivityManager.shared

            // Check if Live Activity exists
            if manager.currentActivity == nil {
                print("🟡 No Live Activity running, starting one first...")
                manager.startActivity()

                // Give it more time to start, then switch to break mode
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("🟢 Now starting break mode: \(duration) minutes")
                    print("🟢 Activity state: \(String(describing: manager.currentActivity?.activityState))")
                    manager.startBreak(durationMinutes: duration)

                    // Schedule background task to update Live Activity when break ends
                    scheduleBackgroundTaskForBreakEnd()
                }
            } else {
                print("🟢 Live Activity exists (state: \(String(describing: manager.currentActivity?.activityState))), starting break: \(duration) minutes")
                manager.startBreak(durationMinutes: duration)

                // Schedule background task to update Live Activity when break ends
                scheduleBackgroundTaskForBreakEnd()
            }
        }

        // Set local state for card UI with animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isOnBreak = true
            breakEndTime = endTime
            breakTimeRemaining = duration * 60
            breakDurationMinutes = duration  // Store for color calculation
        }
    }

    private func updateTimeElapsed() {
        let now = Date()

        // Check if we're within work hours
        let withinHours = checkIsWithinWorkHours()
        isWithinWorkHours = withinHours

        let (start, end) = activePeriod(for: now)

        guard now >= start && now <= end else {
            timeElapsed = 0
            isWithinWorkHours = false
            return
        }

        // SYNC: Use AppGroupStorage as source of truth (widget may have updated it)
        let appGroupLastBreakTime = AppGroupStorage.shared.lastBreakTime

        // If AppGroupStorage has a more recent value, use it (widget was updating while app was closed)
        if appGroupLastBreakTime > lastBreakTime {
            print("📱 App: Using widget's lastBreakTime: \(appGroupLastBreakTime) (was: \(lastBreakTime))")
            lastBreakTime = appGroupLastBreakTime
        } else if lastBreakTime > appGroupLastBreakTime {
            // App has newer value, sync to AppGroupStorage
            AppGroupStorage.shared.lastBreakTime = lastBreakTime
        }

        // Determine baseline: max(lastBreakTime, start of period)
        let baselineTime = max(lastBreakTime, start.timeIntervalSince1970)
        let elapsed = Int(now.timeIntervalSince1970 - baselineTime)
        timeElapsed = max(elapsed, 0)

        // Sync other settings to App Group storage for widget
        AppGroupStorage.shared.breakIntervalMins = breakIntervalMins
        AppGroupStorage.shared.workStartHour = workStartHour
        AppGroupStorage.shared.workStartMinute = workStartMinute
        AppGroupStorage.shared.workEndHour = workEndHour
        AppGroupStorage.shared.workEndMinute = workEndMinute

        // Check and update Live Activity if thresholds crossed
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.checkAndUpdateForTimeElapsed(timeElapsed)
        }

        // Schedule notification if needed
        if notificationPermissionGranted && timeElapsed >= (breakIntervalMins * 60)
            && !NotificationManager.shared.hasScheduledNotification() {
            NotificationManager.shared.scheduleNextBreakNotification()
        }
    }

    /// Returns the active work period start and end for given date, handling wrap past midnight
    private func activePeriod(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = workStartHour
        startComponents.minute = workStartMinute

        var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
        endComponents.hour = workEndHour
        endComponents.minute = workEndMinute

        guard let startDate = calendar.date(from: startComponents),
              let endDateSameDay = calendar.date(from: endComponents) else {
            return (date, date)
        }

        if startDate <= endDateSameDay {
            // Normal same-day period
            return (startDate, endDateSameDay)
        } else {
            // Wraps past midnight: end is next day
            let endDate = calendar.date(byAdding: .day, value: 1, to: endDateSameDay)!
            // If now is before endDateSameDay's components, it means we are after midnight
            if date <= endDateSameDay {
                // Actually it's after midnight, start was yesterday
                let startDatePrev = calendar.date(byAdding: .day, value: -1, to: startDate)!
                return (startDatePrev, endDateSameDay)
            } else {
                // It's before midnight in period start day
                return (startDate, endDate)
            }
        }
    }

    private func updateBreakTime() {
        guard let endTime = breakEndTime else { return }
        let remaining = Int(endTime.timeIntervalSinceNow)

        if remaining <= 0 {
            // Break ended - switch back to work mode
            endBreak()
        } else {
            breakTimeRemaining = remaining
        }
    }

    private func endBreak() {
        // Capture the break end time before clearing (to use as new session start)
        let storage = AppGroupStorage.shared
        let breakEndTimeValue = storage.breakEndTime

        // End break through Live Activity manager FIRST (before clearing storage)
        // This ensures the Live Activity can use breakEndTime to set correct sessionStartTime
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.endBreak()
        }

        // Set lastBreakTime to when the break actually ended (for local UI consistency)
        if breakEndTimeValue > 0 {
            let breakEndDate = Date(timeIntervalSince1970: breakEndTimeValue)
            lastBreakTime = breakEndDate.timeIntervalSince1970
            // Note: LiveActivityManager.endBreak() will also set this in storage asynchronously
        }

        // Clear persisted break state (LiveActivityManager also clears this, but we do it here for immediate UI update)
        storage.isOnBreak = false
        storage.breakEndTime = 0
        storage.breakDurationMinutes = 0

        // Reload widget to show active mode
        WidgetCenter.shared.reloadAllTimelines()

        // Switch back to work mode with animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isOnBreak = false
            breakEndTime = nil
            breakTimeRemaining = 0
            breakDurationMinutes = 0
        }

        print("✅ Break ended - switched back to work mode at \(Date(timeIntervalSince1970: lastBreakTime))")
    }

    private func cancelBreak() {
        // End break through Live Activity manager
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.endBreak()
        }

        // Call endBreak to clean up local state
        endBreak()

        print("🚫 Break cancelled by user")
    }

    private func restoreBreakStateIfNeeded() {
        let storage = AppGroupStorage.shared

        // Check if we were on break
        if storage.isOnBreak && storage.breakEndTime > 0 {
            let endTime = Date(timeIntervalSince1970: storage.breakEndTime)
            let now = Date()

            // Check if break is still active
            if endTime > now {
                // Restore break state
                isOnBreak = true
                breakEndTime = endTime
                breakTimeRemaining = Int(endTime.timeIntervalSinceNow)
                breakDurationMinutes = storage.breakDurationMinutes  // Restore duration for color calculation
                print("✅ Restored break state - \(breakTimeRemaining)s remaining")
            } else {
                // Break already ended, clean up
                endBreak()
                print("🟡 Break already ended, cleaning up")
            }
        }
    }

    /// Schedule background task to update Live Activity when break ends
    private func scheduleBackgroundTaskForBreakEnd() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.scheduleBackgroundLiveActivityRefresh()
            print("📅 Scheduled background task for break end")
        }
    }

    /// Check if current time is within work hours
    private func checkIsWithinWorkHours() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let startSecs = (workStartHour * 3600) + (workStartMinute * 60)
        let endSecs = (workEndHour * 3600) + (workEndMinute * 60)

        if startSecs <= endSecs {
            // No midnight wrap
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            // Wraps past midnight
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }
}

func formattedTime(_ totalSeconds: Int) -> String {
    let hours = (totalSeconds / 3600)
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

#Preview {
    SedentaryTime(notificationPermissionGranted: .constant(true), selectedDuration: .constant(.init(hours: 2, minutes: 2))) { }
}

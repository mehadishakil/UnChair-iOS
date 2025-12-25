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

    // Active hours from AppStorage
    @AppStorage("workStartHour") private var workStartHour: Int = 9
    @AppStorage("workStartMinute") private var workStartMinute: Int = 0
    @AppStorage("workEndHour") private var workEndHour: Int = 17
    @AppStorage("workEndMinute") private var workEndMinute: Int = 0
    @AppStorage("LastBreakTime") private var lastBreakTime: Double = 0

    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme

    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void) {
        self._notificationPermissionGranted = notificationPermissionGranted
        self._selectedDuration = selectedDuration
        self.onTakeBreak = onTakeBreak
    }

    var body: some View {
        ZStack {
            if isOnBreak {
                // Break Mode UI
                HStack {
                    Image(systemName: "hourglass.tophalf.filled")
                        .resizable()
                        .frame(width: 90)
                        .foregroundColor(.orange.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.leading)

                    Spacer()

                    VStack {
                        Text("Break Time")
                            .font(.headline)
                            .foregroundColor(.orange)

                        Spacer()

                        Text(formattedTime(breakTimeRemaining))
                            .font(.largeTitle.bold())
                            .foregroundColor(.orange)

                        Spacer()

                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange.opacity(0.8))
                            Text("Enjoy your break!")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }

                    Spacer()
                }
                .padding()
            } else {
                // Work Mode UI (Original)
                HStack {
                    Image(systemName: "hourglass.tophalf.filled")
                        .resizable()
                        .frame(width: 90)
                        .foregroundColor(.primary.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.leading)

                    Spacer()

                    VStack {
                        Text("Sedentary Time")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(formattedTime(timeElapsed))
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Spacer()

                        HStack(spacing: 8) {
                            // Unchair button with break duration menu
                            Menu {
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
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            .buttonStyle(.plain)

                        // Debug: Start/Stop Live Activity
                        if #available(iOS 16.1, *) {
                            Menu {
                                Button("Reset & Start Fresh") {
                                    // Reset break time to now
                                    let now = Date()
                                    lastBreakTime = now.timeIntervalSince1970
                                    AppGroupStorage.shared.lastBreakTime = now.timeIntervalSince1970

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
        .onAppear {
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
            if isOnBreak {
                updateBreakTime()
            } else {
                updateTimeElapsed()
            }
        }
    }

    private func startBreak(duration: Int) {
        // DON'T call onTakeBreak() to avoid scrolling to exercise section

        // Ensure Live Activity is running before switching to break mode
        if #available(iOS 16.1, *) {
            let manager = LiveActivityManager.shared

            // Check if Live Activity exists
            if manager.currentActivity == nil {
                print("🟡 No Live Activity running, starting one first...")
                manager.startActivity()

                // Give it a moment to start, then switch to break mode
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🟢 Starting break mode: \(duration) minutes")
                    manager.startBreak(durationMinutes: duration)
                }
            } else {
                print("🟢 Live Activity exists, starting break: \(duration) minutes")
                manager.startBreak(durationMinutes: duration)
            }
        }

        // Set local state for card UI
        isOnBreak = true
        breakEndTime = Date().addingTimeInterval(TimeInterval(duration * 60))
        breakTimeRemaining = duration * 60
    }

    private func updateTimeElapsed() {
        let now = Date()
        let (start, end) = activePeriod(for: now)

        guard now >= start && now <= end else {
            timeElapsed = 0
            return
        }

        // Determine baseline: max(lastBreakTime, start of period)
        let baselineTime = max(lastBreakTime, start.timeIntervalSince1970)
        let elapsed = Int(now.timeIntervalSince1970 - baselineTime)
        timeElapsed = max(elapsed, 0)

        // Update App Group storage for widget
        AppGroupStorage.shared.lastBreakTime = lastBreakTime
        AppGroupStorage.shared.breakIntervalMins = selectedDuration.totalMinutes
        AppGroupStorage.shared.workStartHour = workStartHour
        AppGroupStorage.shared.workStartMinute = workStartMinute
        AppGroupStorage.shared.workEndHour = workEndHour
        AppGroupStorage.shared.workEndMinute = workEndMinute

        // Check and update Live Activity if thresholds crossed
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.checkAndUpdateForTimeElapsed(timeElapsed)
        }

        // Schedule notification if needed
        if notificationPermissionGranted && timeElapsed >= (selectedDuration.totalMinutes * 60)
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
        // Switch back to work mode
        isOnBreak = false
        breakEndTime = nil
        breakTimeRemaining = 0

        // Reset work tracking - start fresh session
        let now = Date()
        lastBreakTime = now.timeIntervalSince1970
        AppGroupStorage.shared.lastBreakTime = now.timeIntervalSince1970

        // Live Activity will auto-switch via LiveActivityManager.endBreak()
        // (the timer in LiveActivityManager will handle this automatically)

        print("✅ Break ended - switched back to work mode")
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

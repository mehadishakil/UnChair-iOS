//
//  SedentaryTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/24.
//

import SwiftUI
import Foundation

struct SedentaryTime: View {
    @StateObject private var settings = SettingsManager.shared
    @Binding var notificationPermissionGranted: Bool
    @Binding var selectedDuration: TimeDuration
    @State private var timeElapsed: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let onTakeBreak: () -> Void
    
    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void) {
        self._notificationPermissionGranted = notificationPermissionGranted
        self._selectedDuration = selectedDuration
        self.onTakeBreak = onTakeBreak
    }
    
    var body: some View {
        HStack() {
            Spacer()
            
            Image(systemName: "hourglass.tophalf.filled")
                .resizable()
                .frame(width: 70, height: 100)
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("Sedentary Time")
                    .font(.headline)
                
                Text("\(formattedTime(timeElapsed))")
                    .font(.title3)
                Button {
                    // Save last break time and reschedule notifications when user takes a break
                    NotificationManager.shared.saveLastBreakTime()
                    NotificationManager.shared.scheduleNextBreakNotification()
                    onTakeBreak()
                } label: {
                    Text("Take a Break")
                }.buttonStyle(.bordered)
            }
            Spacer()
        }
        .onAppear {
            // Use the NotificationManager to manage last break time
            NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
            updateTimeElapsed()
            
            // Listen for notification tap events
            NotificationCenter.default.addObserver(
                forName: .breakNotificationTapped,
                object: nil,
                queue: .main
            ) { _ in
                // Reset timer when notification is tapped
                updateTimeElapsed()
            }
            
            // Listen for settings changes
            NotificationCenter.default.addObserver(
                forName: .breakSettingsChanged,
                object: nil,
                queue: .main
            ) { _ in
                // Reschedule notifications when settings change
                NotificationManager.shared.scheduleNextBreakNotification()
            }
        }
        .onDisappear {
            // Clean up observers when view disappears
            NotificationCenter.default.removeObserver(self)
        }
        .onReceive(timer) { _ in
            updateTimeElapsed()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    private func updateTimeElapsed() {
        let now = Date()
        
        // Check if we're within active hours
        if isWithinActiveHours(now) {
            // Get the last break time or default to start time if no break was taken
            let lastBreakTime = NotificationManager.shared.getLastBreakTime() ?? getActiveHourStartForToday()
            
            // Calculate elapsed time from last break or start of active hours
            let elapsed = Int(now.timeIntervalSince(lastBreakTime))
            timeElapsed = max(elapsed, 0)
            
            // Schedule notification if needed and we have permission
            if notificationPermissionGranted &&
               timeElapsed >= (selectedDuration.totalMinutes * 60) &&
               !NotificationManager.shared.hasScheduledNotification() {
                NotificationManager.shared.scheduleNextBreakNotification()
            }
        } else {
            // Outside active hours, no elapsed time
            timeElapsed = 0
        }
    }
    
    private func isWithinActiveHours(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: date)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!
        
        // Get start/end times for today
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
    
    private func getActiveHourStartForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        
        // Combine today's date with start time
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = startTimeComponents.hour
        components.minute = startTimeComponents.minute
        
        return calendar.date(from: components) ?? now
    }
}

func formattedTime(_ totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let min = (totalSeconds % 3600) / 60
    let sec = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, min, sec)
}

//#Preview {
//    SedentaryTime(notificationPermissionGranted: .constant(false) ,selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
//}

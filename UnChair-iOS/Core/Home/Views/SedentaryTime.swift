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
    @State private var notificationScheduled = false
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
                    // Save last break time when user takes a break
                    saveLastBreakTime()
                    onTakeBreak()
                } label: {
                    Text("Take a Break")
                }.buttonStyle(.bordered)
            }
            Spacer()
        }
        .onAppear {
            // Fix: Check and reset break time BEFORE calculating elapsed time
            checkAndResetLastBreakTimeIfNeeded()
            updateTimeElapsed()
        }
        .onReceive(timer) { _ in
            updateTimeElapsed()
            if notificationPermissionGranted {
                performScheduleNotification()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    private func updateTimeElapsed() {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if we're within active hours
        if isWithinActiveHours(now) {
            // Get the last break time or default to start time if no break was taken
            let lastBreakTime = getLastBreakTime() ?? getActiveHourStartForToday()
            
            // Calculate elapsed time from last break or start of active hours
            let elapsed = Int(now.timeIntervalSince(lastBreakTime))
            timeElapsed = max(elapsed, 0)
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
    
    private func saveLastBreakTime() {
        let now = Date()
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastBreakTime")
        UserDefaults.standard.set(Calendar.current.dateComponents([.year, .month, .day], from: now).day, forKey: "lastBreakDay")
        // Also store the month and year to handle month/year changes correctly
        UserDefaults.standard.set(Calendar.current.dateComponents([.year, .month, .day], from: now).month, forKey: "lastBreakMonth")
        UserDefaults.standard.set(Calendar.current.dateComponents([.year, .month, .day], from: now).year, forKey: "lastBreakYear")
    }
    
    private func getLastBreakTime() -> Date? {
        // Check if we need to reset first - this ensures we don't get outdated data
        if shouldResetLastBreakTime() {
            return nil
        }
        
        let lastBreakTimeInterval = UserDefaults.standard.double(forKey: "lastBreakTime")
        if lastBreakTimeInterval > 0 {
            return Date(timeIntervalSince1970: lastBreakTimeInterval)
        }
        return nil
    }
    
    private func shouldResetLastBreakTime() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        let lastBreakDay = UserDefaults.standard.integer(forKey: "lastBreakDay")
        let lastBreakMonth = UserDefaults.standard.integer(forKey: "lastBreakMonth")
        let lastBreakYear = UserDefaults.standard.integer(forKey: "lastBreakYear")
        
        // If we have no stored last break data, no need to reset
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
    
    private func checkAndResetLastBreakTimeIfNeeded() {
        if shouldResetLastBreakTime() {
            // Clear last break time data
            UserDefaults.standard.removeObject(forKey: "lastBreakTime")
            UserDefaults.standard.removeObject(forKey: "lastBreakDay")
            UserDefaults.standard.removeObject(forKey: "lastBreakMonth")
            UserDefaults.standard.removeObject(forKey: "lastBreakYear")
        }
    }
    
    private func isNewActivePeriod(_ now: Date) -> Bool {
        let calendar = Calendar.current
        let lastBreakTimeInterval = UserDefaults.standard.double(forKey: "lastBreakTime")
        
        if lastBreakTimeInterval > 0 {
            let lastBreakTime = Date(timeIntervalSince1970: lastBreakTimeInterval)
            
            // Check if the last break was in a previous active period
            let nowComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
            let lastBreakComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: lastBreakTime)
            
            // If dates are different, it's a new day
            if nowComps.year != lastBreakComps.year || nowComps.month != lastBreakComps.month || nowComps.day != lastBreakComps.day {
                return true
            }
            
            // Get end time for comparison
            let endComps = calendar.dateComponents([.hour, .minute], from: settings.endTime)
            let startComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
            
            // Check if last break was before end time but now is after start time of a new period
            let lastBreakTotalMinutes = (lastBreakComps.hour! * 60) + lastBreakComps.minute!
            let endTotalMinutes = (endComps.hour! * 60) + endComps.minute!
            let nowTotalMinutes = (nowComps.hour! * 60) + nowComps.minute!
            let startTotalMinutes = (startComps.hour! * 60) + startComps.minute!
            
            // If start time is after end time (spanning midnight)
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
                // If last break was during previous active period and now we're in a new one
                if (lastBreakTotalMinutes <= endTotalMinutes && lastBreakTotalMinutes >= startTotalMinutes) &&
                   ((nowTotalMinutes >= startTotalMinutes && nowTotalMinutes <= endTotalMinutes && lastBreakComps.day != nowComps.day) ||
                    (nowTotalMinutes < startTotalMinutes || nowTotalMinutes > endTotalMinutes)) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func resetTimer() {
        timeElapsed = 0
        notificationScheduled = false
    }
    
    func performScheduleNotification() {
        let timerMin = timeElapsed / 60
        if timerMin >= selectedDuration.totalMinutes {
            if !notificationScheduled {
                scheduleNotification()
                notificationScheduled = true
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.subtitle = "You've been sedentary for \(selectedDuration.totalMinutes) minutes"
        content.body = "Stand up and stretch for a few minutes."
        content.sound = UNNotificationSound.defaultCritical
        content.badge = 1

        // Trigger after 15 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(Date().addingTimeInterval(15))")
                
                // Check pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("Pending notifications: \(requests.count)")
                }
                
                // Check delivered notifications after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
                    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                        print("Delivered notifications: \(notifications.count)")
                        for notification in notifications {
                            print(notification.request.content.title)
                        }
                    }
                }
            }
        }
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

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
    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void)
    {
        self._notificationPermissionGranted = notificationPermissionGranted
        self._selectedDuration             = selectedDuration
        self.onTakeBreak                   = onTakeBreak
    }
    
    var body: some View {
        HStack(){
            Spacer()
            
            Image(systemName: "hourglass.tophalf.filled")
                .resizable()
                .frame(width: 70, height: 100)
            
            Spacer()
            
            VStack(alignment : .center){
                Text("Sedentary Time")
                    .font(.headline)
                
                Text("\(formattedTime(timeElapsed))")
                    .font(.title3)
                Button{
                    onTakeBreak()
                }label: {
                    Text("Take a Break")
                }.buttonStyle(.bordered)
            }
            Spacer()
        }
        .onAppear {
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
        let now      = Date()
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600)
                        + (nowComps.minute! * 60)
                        +  nowComps.second!

        // start/end in seconds‑of‑day
        let startComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        let endComps   = calendar.dateComponents([.hour, .minute], from: settings.endTime)
        let startSecs = (startComps.hour! * 3600) + (startComps.minute! * 60)
        let endSecs   = (endComps.hour!   * 3600) + (endComps.minute!   * 60)

        var elapsed = 0

        if startSecs <= endSecs {
            // no midnight wrap
            if currentSecs >= startSecs && currentSecs <= endSecs {
                elapsed = currentSecs - startSecs
            }
        } else {
            // wraps past midnight
            if currentSecs >= startSecs {
                // later the same evening
                elapsed = currentSecs - startSecs
            } else if currentSecs <= endSecs {
                // after midnight
                elapsed = (24 * 3600 - startSecs) + currentSecs
            }
        }

        timeElapsed = max(elapsed, 0)
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

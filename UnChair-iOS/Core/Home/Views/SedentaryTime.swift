//
//  SedentaryTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/24.
//

import SwiftUI

struct SedentaryTime: View {
    
    @State private var notificationScheduled = false
    @Binding var notificationPermissionGranted: Bool
    @Binding var selectedDuration: TimeDuration
    @State var startTime = Date.now
    @State var timeElapsed : Int = 0
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                    .onReceive(timer){ firedDate in
                        timeElapsed = Int(firedDate.timeIntervalSince(startTime))
                    }
                Button{
                    startTime = Date.now
                }label: {
                    Text("Reset")
                }.buttonStyle(.bordered)
            }
            Spacer()
        }
        .onReceive(timer) { firedDate in
            timeElapsed = Int(firedDate.timeIntervalSince(startTime))
            if notificationPermissionGranted {
                performScheduleNotification()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
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



#Preview {
    SedentaryTime(notificationPermissionGranted: .constant(false) ,selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}

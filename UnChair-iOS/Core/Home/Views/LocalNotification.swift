//  LocalNotification.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/8/24.

import SwiftUI
import UserNotifications

struct LocalNotification: View {
    var body: some View {
        VStack{
            Button("Schedule Notification"){
                scheduleNotification()
            }
            .buttonStyle(.bordered)
        }
    }
    
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "This is the title"
        content.subtitle = "This is the subtitle"
        content.sound = UNNotificationSound.default
        // Trigger after 10 sec
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // add notification request
        UNUserNotificationCenter.current().add(request)
    }
    
}

#Preview {
    LocalNotification()
}

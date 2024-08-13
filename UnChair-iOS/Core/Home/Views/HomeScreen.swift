//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @Binding var selectedDuration: TimeDuration
    @State private var notificationPermissionGranted = false
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    HeaderView()
                    HCalendarView().padding(.bottom)
                    SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted ,selectedDuration: $selectedDuration).padding()
                    DailyTracking()
                    Spacer()
                    BreakSectionView()
                        .padding(.bottom)
                    
                    CalmCorner()
                        
                        
                    
//                    NavigationLink(destination: LocalNotification()) {
//                        HStack {
//                            Image(systemName: "creditcard")
//                            Text("Restore Purchase")
//                            Spacer()
//                        }
//                    }
                    
                    
                }
                .onAppear{
                    requestNotificationPermission()
                }
            }
        }
    }
    
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = success
                if success {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HomeScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}

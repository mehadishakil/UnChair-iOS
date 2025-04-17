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
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    
    var body: some View {
        NavigationStack{
            ScrollViewReader { proxy in
                ScrollView{
                    ZStack{
                        Color.backgroundtheme.opacity(0.7)
                        VStack{
                            HeaderView()
                            HCalendarView().padding(.bottom)
                            
                            SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted ,selectedDuration: $selectedDuration)
                            {
                                withAnimation {
                                    proxy.scrollTo("breakSection", anchor: .top)
                                }
                            }
                            .padding()
                            
                            DailyTracking()
                            
                            Spacer()
                            
                            BreakSectionView()
                                .id("breakSection")
                            
                            CalmCorner()
                        }}
                    .onAppear {
                        requestNotificationPermission()
                        healthViewModel.refreshData()
                    }
                    .refreshable {
                        healthViewModel.refreshData()
                    }
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

//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @Binding var selectedDuration: TimeDuration
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    HeaderView()
                    HCalendarView().padding(.bottom)
                    SedentaryTime(selectedDuration: $selectedDuration).padding()
                    DailyTracking()
                    Spacer()
                    BreakSectionView()
                        .padding(.bottom)
                    
                    
                        NavigationLink(destination: LocalNotification()) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Restore Purchase")
                                Spacer()
                            }
                        }
                    
                }
                .onAppear{
                    requestNotificationPermission()
                }
            }
        }
    }
    
    
    func requestNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){ success, error in
            if success{
                print("Granted")
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    HomeScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}

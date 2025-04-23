//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

//struct HomeScreen: View {
//    @Binding var selectedDuration: TimeDuration
//    @State private var notificationPermissionGranted = false
//    @EnvironmentObject var healthViewModel: HealthDataViewModel
//    
//    var body: some View {
//        NavigationStack{
//            ScrollViewReader { proxy in
//                ScrollView{
//                    ZStack{
//                        Color.backgroundtheme.opacity(0.7)
//                        VStack{
//                            HeaderView()
//                            HCalendarView().padding(.bottom)
//                            
//                            SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted ,selectedDuration: $selectedDuration)
//                            {
//                                withAnimation {
//                                    proxy.scrollTo("breakSection", anchor: .top)
//                                }
//                            }
//                            .padding()
//                            
//                            DailyTracking()
//                            
//                            Spacer()
//                            
//                            BreakSectionView()
//                                .id("breakSection")
//                            
//                            CalmCorner()
//                        }}
//                    .onAppear {
//                        requestNotificationPermission()
//                        healthViewModel.refreshData()
//                    }
//                    .refreshable {
//                        healthViewModel.refreshData()
//                    }
//                }
//            }
//        }
//        
//    }
//    
//    
//    
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
//            DispatchQueue.main.async {
//                self.notificationPermissionGranted = success
//                if success {
//                    print("Notification permission granted")
//                } else if let error = error {
//                    print("Error requesting notification permission: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//}



struct HomeScreen: View {
    @Binding var selectedDuration: TimeDuration
    @State private var notificationPermissionGranted = false
    @State private var showDetail = false
    @Namespace private var namespace
    @EnvironmentObject var healthViewModel: HealthDataViewModel

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack {
                            Color.backgroundtheme.opacity(0.7)
                                .ignoresSafeArea()
                            VStack(spacing: 0) {
                                HeaderView()
                                HCalendarView()
                                    .padding(.bottom)

                                SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted,
                                              selectedDuration: $selectedDuration) {
                                    withAnimation {
                                        proxy.scrollTo("breakSection", anchor: .top)
                                    }
                                }
                                .padding()

                                DailyTracking()


                                breakSectionView
                                    .id("breakSection")

                                CalmCorner()
                            }
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
        }
        // full-screen overlay for details
        .fullScreenCover(isPresented: $showDetail) {
                    // tap to dismiss:
                    BreakDetailsView(namespace: namespace, show: $showDetail, breakItem: breakList[0])
                        .ignoresSafeArea()
                }
    }
    
    var breakSectionView: some View {
        VStack {
            Text("Take a break".uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            ScrollView {
                if !showDetail {
                    BreakItem(namespace: namespace, show: $showDetail, breakItem: breakList[0])
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showDetail.toggle()
                            }
                        }
                }
            }
        }
    }


    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = success
                if !success, let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
}



#Preview {
    HomeScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}

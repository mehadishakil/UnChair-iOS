//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var selectedDuration = TimeDuration(hours: 0, minutes: 1)
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @EnvironmentObject private var authController: AuthController
    @EnvironmentObject private var healthViewModel: HealthDataViewModel
    

    var body: some View {
        TabView {
            HomeScreen(selectedDuration: $selectedDuration)
                .tabItem { Label("Home", systemImage: "house") }
                .onAppear { healthViewModel.refreshData() }

            AnalyticScreen()
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }


            SettingsScreen(selectedDuration: $selectedDuration)
                .tabItem { Label("Library", systemImage: "gearshape.fill") }
        }
        .background(.ultraThinMaterial)
        .edgesIgnoringSafeArea(.bottom)
        .tint(.primary)
        .preferredColorScheme(userTheme.colorScheme)
        .onAppear {
            if let uid = authController.currentUser?.uid {
                healthViewModel.setUserId(uid)
            }
        }
    }
}


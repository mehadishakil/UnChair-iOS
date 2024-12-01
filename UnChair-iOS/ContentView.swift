//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var tabBarVisible = true
    @State private var selectedDuration = TimeDuration(hours: 0, minutes: 1)
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        
        TabView{
            HomeScreen(selectedDuration: $selectedDuration)
                .tabItem {
                    Image(systemName: "house")
                }
            AnalyticScreen()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                }
            ProfileScreen(selectedDuration: $selectedDuration)
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .edgesIgnoringSafeArea(.all)
        .tint(.primary)
        .preferredColorScheme(userTheme.colorScheme)
        
        
    }
    
}

#Preview {
    ContentView()
}

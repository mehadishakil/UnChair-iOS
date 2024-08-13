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
    
    var body: some View {

            TabView{
                    HomeScreen(selectedDuration: $selectedDuration)
                        .badge(2)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    AnalyticScreen()
                        .tabItem {
                            Label("Analytics", systemImage: "chart.bar.xaxis")
                        }
                    ProfileScreen(selectedDuration: $selectedDuration)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
            }
        
        
    }
}

#Preview {
    ContentView()
}

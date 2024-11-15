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
    // @State private var changeTheme: Bool = false
    
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
        
        
    }
    
}

#Preview {
    ContentView()
}

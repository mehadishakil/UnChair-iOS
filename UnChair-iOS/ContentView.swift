//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var tabBarVisible = true
    
    var body: some View {
        TabView{
                HomeScreen()
                    .badge(2)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                AnalyticScreen()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    }
                ProfileScreen()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }

        }
        
    }
}

#Preview {
    ContentView()
}

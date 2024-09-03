//
//  UnChair_iOSApp.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/5/24.
//

import SwiftUI
import UserNotifications

@main
struct UnChair_iOSApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var body: some Scene {
        WindowGroup {
//            if isOnboarding {
//                OnBoarding()
//            } else {
//                ContentView()
//            }
            
            ContentView()
        }
    }
}

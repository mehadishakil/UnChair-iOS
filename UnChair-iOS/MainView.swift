//
//  MainView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct MainView: View {
    
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    
    var body: some View {
        Group{
            switch authController.authState {
            case .undefined:
                ProgressView()
            case .authenticated:
                ContentView()
                    .onAppear {
                        if let userId = authController.currentUser?.uid {
                            healthViewModel.setUserId(userId)
                        }
                    }
                    .presentPaywallIfNeeded(requiredEntitlementIdentifier: "pro")
            case .unauthenticated:
                Authentication()
            }
        }
        .task {
            await authController.startListeningToAuthState()
        }
    }
}

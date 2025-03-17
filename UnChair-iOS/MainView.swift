//
//  MainView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI

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
            case .unauthenticated:
                Authentication()
            }
        }
        .task {
            await authController.startListeningToAuthState()
        }
    }
}

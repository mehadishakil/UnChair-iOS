//
//  MainView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        Group{
            switch authController.authState {
            case .undefined:
                ProgressView()
            case .authenticated:
                ContentView()
            case .unauthenticated:
                Authentication()
            }
        }
        .task {
            await authController.startListeningToAuthState()
        }
    }
}

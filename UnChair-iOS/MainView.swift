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
    
    // State to track subscription status
    @State private var isSubscriptionActive = false
    @State private var isLoadingSubscription = true
    @State private var customerInfo: CustomerInfo?
    
    var body: some View {
        Group {
            switch authController.authState {
            case .undefined:
                ProgressView()
            case .authenticated:
                if isLoadingSubscription {
                    ProgressView("Checking subscription...")
                } else if isSubscriptionActive {
                    // User has active subscription - show main content
                    ContentView()
                        .onAppear {
                            if let userId = authController.currentUser?.uid {
                                healthViewModel.setUserId(userId)
                            }
                        }
                } else {
                    // User doesn't have subscription - show paywall
                    PaywallView(displayCloseButton: false)
                        .onPurchaseCompleted { customerInfo in
                            // Handle successful purchase
                            self.customerInfo = customerInfo
                            checkSubscriptionStatus()
                        }
                        .onRestoreCompleted { customerInfo in
                            // Handle successful restore
                            self.customerInfo = customerInfo
                            checkSubscriptionStatus()
                        }
                }
            case .unauthenticated:
                Authentication()
            }
        }
        .task {
            await authController.startListeningToAuthState()
        }
        .onChange(of: authController.authState) { oldState, newState in
            if newState == .authenticated {
                // When user becomes authenticated, check their subscription
                checkSubscriptionStatus()
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        isLoadingSubscription = true
        
        Purchases.shared.getCustomerInfo { customerInfo, error in
            DispatchQueue.main.async {
                self.isLoadingSubscription = false
                
                if let customerInfo = customerInfo {
                    self.customerInfo = customerInfo
                    // Check if user has the "pro" entitlement
                    self.isSubscriptionActive = customerInfo.entitlements["pro"]?.isActive == true
                } else if let error = error {
                    print("Error fetching customer info: \(error.localizedDescription)")
                    // In case of error, assume no subscription
                    self.isSubscriptionActive = false
                }
            }
        }
    }
}

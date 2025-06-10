//
//  MainView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/12/24.
//


import SwiftUI
import RevenueCat
import RevenueCatUI
import StoreKit

struct MainView: View {
    
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    @Environment(\.requestReview) var requestReview : RequestReviewAction
    
    @State private var isSubscriptionActive = false
    @State private var isLoadingSubscription = true
    @State private var customerInfo: CustomerInfo?
    
    var body: some View {
        Group {
            switch authController.authState {
            case .undefined:
                NavigationStack {
                    SignupView()
                }
            case .authenticated:
                if isLoadingSubscription {
                    ProgressView("Checking subscription...")
                } else if isSubscriptionActive {
                    ContentView()
                        .onAppear {
                            if let userId = authController.currentUser?.uid {
                                healthViewModel.setUserId(userId)
                            }
                        }
                } else {
                    PaywallView(displayCloseButton: false)
                        .onPurchaseCompleted { customerInfo in
                            self.customerInfo = customerInfo
                            checkSubscriptionStatus()
                            requestReview()
                        }
                        .onRestoreCompleted { customerInfo in
                            self.customerInfo = customerInfo
                            checkSubscriptionStatus()
                        }
                }
            case .unauthenticated:
                NavigationStack {
                    SigninView()
                }
            case .authenticating:
                ProgressView()
            }
        }
        .task {
            await authController.startListeningToAuthState()
        }
        .onChange(of: authController.authState) { oldState, newState in
            if newState == .authenticated {
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
                    self.isSubscriptionActive = customerInfo.entitlements["pro"]?.isActive == true
                } else if let error = error {
                    print("Error fetching customer info: \(error.localizedDescription)")
                    self.isSubscriptionActive = false
                }
            }
        }
    }
}

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
    @State private var showSubscriptionError = false
    
    var body: some View {
        ZStack{
            Group {
                switch authController.authState {
                case .undefined:
                    ProgressView("Checking login…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                case .unauthenticated:
                    NavigationStack {
                        SigninView()
                    }
                case .authenticated:
                    if isLoadingSubscription {
                        ProgressView("Checking subscription...")
                    } else if isSubscriptionActive {
                        ContentView()
                            .transition(.opacity)
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
                            .transition(.opacity)
                    }
                }
            }
        }
        .animation(.easeInOut, value: authController.authState)
        .task {
            await authController.startListeningToAuthState()
        }
        .onChange(of: authController.authState) { _, newState in
            if newState == .authenticated && customerInfo == nil {
                checkSubscriptionStatus()
            }
        }
        .alert("Subscription Error", isPresented: $showSubscriptionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("We couldn't verify your subscription. Please try again later.")
        }
    }
    
    private func checkSubscriptionStatus() {
        isLoadingSubscription = true
        
        Purchases.shared.getCustomerInfo { customerInfo, error in
            DispatchQueue.main.async {
                self.isLoadingSubscription = false
                
                if let customerInfo = customerInfo {
                    self.customerInfo = customerInfo
                    
                    if let entitlement = customerInfo.entitlements["pro"] {
                        self.isSubscriptionActive = entitlement.isActive
                    } else {
                        print("⚠️ 'pro' entitlement not found")
                        self.isSubscriptionActive = false
                        self.showSubscriptionError = true
                    }
                    
                    // Set user ID after successful subscription check
                    if let userId = authController.currentUser?.uid {
                        healthViewModel.setUserId(userId)
                    }
                    
                } else if let error = error {
                    print("❌ Error fetching customer info: \(error.localizedDescription)")
                    self.isSubscriptionActive = false
                    self.showSubscriptionError = true
                }
            }
        }
    }
}

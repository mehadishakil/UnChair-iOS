//
//  BounceLocationView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 29/5/25.
//


import SwiftUI
import FirebaseAuth
import RevenueCat
import RevenueCatUI

struct ManageSubscription: View {
    
    @State private var showAlert = false
    @State private var isRestoring = false
    @State private var displayPaywall = false
    
    // Plan-related states
    @State private var planTitle: String = "N/A"
    @State private var remainingDays: Int = 0
    @State private var planCost: String = "$0.00"
    @State private var billingDate: String = "N/A"
    
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        VStack {
            Form {
                // Your subscription plan
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(planTitle)
                                .font(.title.bold())
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(remainingDays) days remaining")
                                .font(.footnote)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * CGFloat(min(Double(remainingDays) / 30.0, 1.0)), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                            .padding(.bottom, 4)
                        }
                        
                        VStack(spacing: 16) {
                            PlanDetailRow(title: "Cost", value: planCost)
                            PlanDetailRow(title: "Billed on", value: billingDate)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        restoreSubscription()
                    }) {
                        HStack {
                            Text("Restore subscription")
                                .font(.callout)
                            if isRestoring {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        displayPaywall.toggle()
                    }) {
                        HStack {
                            Text("Switch plan")
                                .font(.callout)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .sheet(isPresented: self.$displayPaywall) {
                        PaywallView(displayCloseButton: true)
                    }
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        HStack {
                            Text("Cancel subscription")
                                .font(.callout)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Cancel Subscription"),
                            message: Text("Are you sure you want to cancel your subscription? This will log you out."),
                            primaryButton: .destructive(Text("Cancel Subscription")) {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
        .onAppear {
            fetchSubscriptionInfo()
        }
    }
    
    // MARK: - Restore Subscription and Fetch Info
    
    func restoreSubscription() {
        isRestoring = true
        Purchases.shared.restorePurchases { customerInfo, error in
            DispatchQueue.main.async {
                self.isRestoring = false
                if let customerInfo = customerInfo {
                    self.updatePlanDetails(from: customerInfo)
                } else if let error = error {
                    print("Restore failed:", error)
                }
            }
        }
    }
    
    func fetchSubscriptionInfo() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            DispatchQueue.main.async {
                    if let customerInfo = customerInfo {
                        updatePlanDetails(from: customerInfo)
                    }
                }
        }
    }
    
    func updatePlanDetails(from customerInfo: CustomerInfo) {
        guard let entitlement = customerInfo.entitlements.active.first?.value else {
            print("No active entitlements found.")
            return
        }
        
        let productId = entitlement.productIdentifier
        planTitle = productId.contains("unchair_monthly_subscription") ? "Monthly" : "Annual"

        
        // Fetch price from RevenueCat offerings (optional)
        Purchases.shared.getOfferings { offerings, _ in
            if let product = offerings?.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == productId }) {
                planCost = product.localizedPriceString
            }
        }
        
        if let expirationDate = entitlement.expirationDate {
            let remaining = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
            remainingDays = max(0, remaining)
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            billingDate = formatter.string(from: expirationDate)
        } else {
            remainingDays = 0
            billingDate = "N/A"
        }
    }
}

struct PlanDetailRow: View {
    let title: String
    let value: String
    var hasIcon: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

struct BounceLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ManageSubscription()
    }
}

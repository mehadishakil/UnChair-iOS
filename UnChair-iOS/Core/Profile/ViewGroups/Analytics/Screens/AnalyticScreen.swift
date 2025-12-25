//
//  AnalyticScreen.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 10/9/24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

class SubscriptionChecker: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = true
    
    private let premiumEntitlementID = "UnChair Premium"
    
    init() {
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        isLoading = true
        
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Error fetching customer info: \(error.localizedDescription)")
                    self?.isPremium = false
                    return
                }
                
                guard let customerInfo = customerInfo else {
                    self?.isPremium = false
                    return
                }
                
                if let entitlement = customerInfo.entitlements[self?.premiumEntitlementID ?? ""] {
                    self?.isPremium = entitlement.isActive
                } else {
                    self?.isPremium = false
                }
            }
        }
    }
    
    func refreshSubscriptionStatus() {
        checkSubscriptionStatus()
    }
}

struct PremiumFeatureCard: View {
    let title: String
    let icon: String
    let description: String
    let onTap: () -> Void
    
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                .foregroundColor(.blue)
                            Text(title)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        Text(description)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Premium")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                VStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Premium Feature")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Upgrade to Premium to access detailed \(title.lowercased()) analytics and insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("Tap to upgrade")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                }
                .frame(minHeight: 140)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            userTheme == .system
            ? (colorScheme == .light ? .white : Color(.secondarySystemBackground))
                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        )
        .cornerRadius(16)
        .shadow(radius: 8)
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnalyticScreen: View {
    @StateObject private var subscriptionChecker = SubscriptionChecker()
    @State private var showPaywall = false
    
    var body: some View {
        ScrollView{
            VStack{
                // Water Chart - FREE
                WaterBarChartView()
                    .padding(.horizontal)

                // Steps Chart - FREE
                StepsLineChartView()
                    .padding()

                // Sleep Chart - FREE
                SleepCapsuleChartView()
                    .padding(.horizontal)
                
                // Exercise Chart
                if subscriptionChecker.isPremium {
                    ExerciseMultiLineChartView()
                        .padding()
                } else {
                    PremiumFeatureCard(
                        title: "Exercise",
                        icon: "figure.strengthtraining.traditional",
                        description: "Track your workout progress",
                        onTap: { showPaywall = true }
                    )
                    .padding(.horizontal)
                }
                
                // Meditation Chart
                if subscriptionChecker.isPremium {
                    MeditationLollipopChartView()
                        .padding(.horizontal)
                        .padding(.bottom)
                } else {
                    PremiumFeatureCard(
                        title: "Meditation",
                        icon: "brain.head.profile",
                        description: "Monitor your mindfulness journey",
                        onTap: { showPaywall = true }
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(displayCloseButton: true)
                .onPurchaseCompleted { _ in
                    subscriptionChecker.refreshSubscriptionStatus()
                }
                .onRestoreCompleted { _ in
                    subscriptionChecker.refreshSubscriptionStatus()
                }
        }
        .onAppear {
            subscriptionChecker.checkSubscriptionStatus()
        }
    }
}

#Preview {
    AnalyticScreen()
}

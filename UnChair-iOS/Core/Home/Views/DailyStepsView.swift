//
//  DailyStepsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyStepsView: View {
    @EnvironmentObject private var healthVM: HealthDataViewModel
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("stepsGoal") private var stepsGoal: Int = 10000

    var progress: Double {
        guard stepsGoal > 0 else { return 0.0 }
        return min(Double(healthVM.stepCount) / Double(stepsGoal), 1.0)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 36)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .foregroundColor(userTheme == .light ? .darkGray : .white.opacity(0.9))
                
                Spacer()
                
                Text("\(healthVM.stepCount)")
                    .font(.system(.title, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Steps")
                        .font(.system(.callout, weight: .medium))
                        .foregroundColor(.primary)
                    
                    GeometryReader { geo in
                        let percent = CGFloat(healthVM.stepCount) / CGFloat(stepsGoal)
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: geo.size.width * CGFloat(percent), height: 6)
                        }
                    }
                }
                .padding(.bottom, 4)
            }
            .padding()
        }
        .frame(height: 170)
        .background(
            userTheme == .system
            ? (colorScheme == .light ? .white : .darkGray)
                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        )
        .cornerRadius(20, corners: .allCorners)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onDisappear {
            if healthVM.stepCount > 0 {
                healthVM.updateStepCount(healthVM.stepCount)
            }
        }
    }
}

#Preview {
    DailyStepsView()
}

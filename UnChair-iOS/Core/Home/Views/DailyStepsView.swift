//
//  DailyStepsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyStepsView: View {
    @EnvironmentObject private var healthVM: HealthDataViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
            
            VStack(spacing: 16) {
                Image("walk")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                Text("\(healthVM.stepCount)")
                    .font(.system(.title, weight: .bold))
                    .foregroundColor(.primary)
                Text("Steps")
                    .font(.system(.callout, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .frame(height: 170)
        .shadow(color: Color.black.opacity(0.15), radius: 8)
        .onDisappear {
            if healthVM.stepCount > 0 {
                healthVM.updateStepCount(healthVM.stepCount)
            }
        }
    }
}

#Preview {
    DailyStepsView()
        .environmentObject(HealthManager())
}

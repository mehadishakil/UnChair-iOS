//
//  DailyTracking.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 9/7/24.
//

import SwiftUI

struct DailyTracking: View {
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Tracking".uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                DailyStepsView()
                DailyWaterView()
            }
            .frame(maxWidth: .infinity)
            
            DailySleepView()
                .frame(maxWidth: .infinity)
        }
        .padding()
        .overlay {
            if healthViewModel.isLoading {
                ProgressView()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    DailyTracking()
}

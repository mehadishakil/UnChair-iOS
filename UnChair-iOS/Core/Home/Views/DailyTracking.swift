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
        VStack(alignment: .leading, spacing: 16) {
            Text("Activities")
                .font(.title2.weight(.semibold))
            
            HStack(spacing: 16) {
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

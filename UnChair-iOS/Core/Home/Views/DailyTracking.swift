//
//  DailyTracking.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 9/7/24.
//

import SwiftUI

struct DailyTracking: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Tracking")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(5)
            
            HStack(spacing: 15) {
                DailyStepsView()
                    .environmentObject(HealthManager())
                DailyWaterView()
            }
            .frame(maxWidth: .infinity)
            
            DailySleepView(sleep: 6.5)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    DailyTracking()
}

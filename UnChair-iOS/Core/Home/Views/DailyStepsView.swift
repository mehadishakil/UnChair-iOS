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
    GlassCard {
      VStack(spacing: 16) {
        Image(systemName: "figure.walk")
          .font(.system(size: 40))
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundStyle(Color.primary.opacity(0.8))
        Text("\(healthVM.stepCount)")
          .font(.system(.title, weight: .bold))
        Text("Steps")
          .font(.system(.subheadline, weight: .medium))
          .foregroundColor(.secondary)
      }
    }
    .onDisappear {
      if healthVM.stepCount > 0 {
        healthVM.updateStepCount(healthVM.stepCount)
      }
    }
  }
}

struct StepsCardView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    DailyStepsView()
        .environmentObject(HealthManager())
}

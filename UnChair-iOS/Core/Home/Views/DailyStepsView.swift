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
              .fill(Color.blue.quaternary)
          
          
            VStack(spacing: 16) {
              Image(systemName: "shoeprints.fill")
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(Color.white)
              Text("\(healthVM.stepCount)")
                .font(.system(.title, weight: .bold))
                .foregroundColor(.white)
              Text("Steps")
                    .font(.system(.title2, weight: .medium))
                .foregroundColor(.white)
            }
            .padding()
          
          
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

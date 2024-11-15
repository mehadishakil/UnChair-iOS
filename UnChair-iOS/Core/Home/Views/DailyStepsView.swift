//
//  DailyStepsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyStepsView: View {
    @EnvironmentObject var manager: HealthManager

    var body: some View {
        StepsCardView {
            VStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)

                
                VStack(spacing: 8) {
                    Text("\(manager.todayStepCount)")
                        .font(.system(size: 24, weight: .bold))
 
                    Text("Steps")
                        .font(.system(size: 16, weight: .bold))

                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
        }
        .shadow(radius: 1)
        
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

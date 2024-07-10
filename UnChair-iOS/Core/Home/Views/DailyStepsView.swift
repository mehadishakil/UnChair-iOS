//
//  DailyStepsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//
import SwiftUI

struct DailyStepsView: View {
    var steps: Int

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
                    Text("\(steps)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Text("Steps")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
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
    DailyStepsView(steps: 9982)
}

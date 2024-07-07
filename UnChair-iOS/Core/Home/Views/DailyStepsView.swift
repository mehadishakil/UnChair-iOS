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
                Image(systemName: "figure.walk") // Use system image or your asset
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
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .padding(12)
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
            .padding()
    }
}

struct DailyStepsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyStepsView(steps: 39945)
    }
}

#Preview {
    DailyStepsView(steps: 9982)
}

//
//  WelcomOnBoardingView 2.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//


import SwiftUI

struct OnBoardingCompletionView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        (
                            Text("You’re all set!")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                        Text("We’ve tailored your experience to help you stay active and balanced. Time to take control of your workday.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }

                    Image("no_nech_pain")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    OnBoardingCompletionView()
}

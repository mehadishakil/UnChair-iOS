//
//  WelcomOnBoardingView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//

import SwiftUI

struct WelcomOnBoardingView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        (
                            Text("Feeling ")
                                .font(.title2)
                                .foregroundColor(.primary)
                            + Text("stiff and drained ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            + Text("after long hours at your desk?")
                                .font(.title2)
                                .foregroundColor(.primary)
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                        Text("You’re not alone. Let UnChair help you stay active, healthy, and focused.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }

                    Image("neck_pain")
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
    WelcomOnBoardingView()
}

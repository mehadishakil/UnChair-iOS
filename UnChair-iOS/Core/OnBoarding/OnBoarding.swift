//
//  OnBoarding.swift
//  Food
//
//  Created llby BqNqNNN on 7/12/20.
//

import SwiftUI

struct OnBoarding: View {
    @State private var showNextScreen: Bool = false
    @State private var currentPage: Int = 0
    @State private var isMovingForward: Bool = true // Track direction
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    let totalPages = 5

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    // Header with Back and Skip
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                isMovingForward = false // Set direction to backward
                                currentPage -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(currentPage == 0 ? .gray.opacity(0.3) : .gray.opacity(0.7))
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .clipShape(Circle())
                        }
                        .disabled(currentPage == 0)

                        Spacer()

                        Button("Skip") {
                            hasCompletedOnboarding = true
                            showNextScreen = true
                        }
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Progress Indicator
                    Text("\(currentPage + 1) / \(totalPages)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        


                    // Manual Page Rendering with proper transitions
                    Group {
                        switch currentPage {
                        case 0: StepsSelectionView()
                        case 1: WaterSelectionView()
                        case 2: SleepSelectionView()
                        case 3: WorkHourSelectionView()
                        case 4: BreakIntervalSelectionView()
                        default: EmptyView()
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: isMovingForward ?
                                .move(edge: .trailing).combined(with: .opacity) :
                                .move(edge: .leading).combined(with: .opacity),
                            removal: isMovingForward ?
                                .move(edge: .leading).combined(with: .opacity) :
                                .move(edge: .trailing).combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentPage)


                    // Next Button
                    ZStack {
                                            // Background circle for progress track
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                                .frame(width: 80, height: 80)
                                            
                                            // Progress circle
                                            Circle()
                                                .trim(from: 0, to: CGFloat(currentPage + 1) / CGFloat(totalPages))
                                                .stroke(
                                                    Color(red: 0.2, green: 0.8, blue: 0.6),
                                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                                )
                                                .frame(width: 80, height: 80)
                                                .rotationEffect(.degrees(-90))
                                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                                            
                                            // Next Button
                                            Button(action: {
                                                if currentPage < totalPages - 1 {
                                                    isMovingForward = true // Set direction to forward
                                                    currentPage += 1
                                                } else {
                                                    hasCompletedOnboarding = true
                                                    showNextScreen = true
                                                }
                                            }) {
                                                Image(systemName: currentPage == totalPages - 1 ? "checkmark" : "chevron.right")
                                                    .font(.title)
                                                    .foregroundColor(.white)
                                                    .padding(20)
                                                    .background(userTheme == .light ? Color(red: 0.2, green: 0.25, blue: 0.3) : Color(red: 0.1, green: 0.2, blue: 0.3))
                                                    .clipShape(Circle())
                                                    .shadow(radius: 5)
                                            }
                                        }
                                        .padding(.bottom, 20)

                    // Navigation to HomeView
                    NavigationLink(destination: ContentView(), isActive: $showNextScreen) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea()
    }
}

struct OnBoarding_Previews: PreviewProvider {
    static var previews: some View {
        OnBoarding()
    }
}

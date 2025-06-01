//
//  OnBoarding.swift
//  Food
//
//  Created llby BqNqNNN on 7/12/20.
//

import SwiftUI

struct OnBoarding: View {
    let totalPages = 5 // Fixed to match actual number of views
    @State private var showNextScreen: Bool = false
    @State private var currentPage: Int = 0
    @State private var isMovingForward: Bool = true
    
    // AppStorage for all user preferences
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("stepsGoal") private var stepsGoal: Int = 10000
    @AppStorage("waterGoalML") private var waterGoalML: Int = 2500
    @AppStorage("sleepGoalMins") private var sleepGoalMins: Int = 480 // 8 hours default
    @AppStorage("breakIntervalMins") private var breakIntervalMins: Int = 60 // 1 hour default
    
    // State variables for temporary selections
    @State private var selectedSteps: Int = 10000
    @State private var selectedWater: Int = 2500
    @State private var selectedSleep: TimeDuration = TimeDuration(hours: 8, minutes: 0)
    @State private var selectedBreakInterval: TimeDuration = TimeDuration(hours: 1, minutes: 0)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    // Header with Back and Skip
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                isMovingForward = false
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
                            saveAllGoals()
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
                    
                    // Page content with proper data binding
                    Group {
                        switch currentPage {
                        case 0:
                            StepsSelectionView(selectedSteps: $selectedSteps)
                        case 1:
                            WaterSelectionView(selectedWater: $selectedWater)
                        case 2:
                            SleepSelectionView(selectedSleep: $selectedSleep)
                        case 3:
                            BreakIntervalSelectionView(selectedBreakInterval: $selectedBreakInterval)
                        case 4:
                            WorkHourSelectionView()
                        default:
                            EmptyView()
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
                    
                    // Next Button with progress circle
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
                            handleNextButtonTap()
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
                    
                    // Navigation to MainView
                    NavigationLink(destination: MainView(), isActive: $showNextScreen) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea()
        .onAppear {
            // Load existing values if available
            selectedSteps = stepsGoal
            selectedWater = waterGoalML
            selectedSleep = TimeDuration(fromTotalMinutes: sleepGoalMins)
            selectedBreakInterval = TimeDuration(fromTotalMinutes: breakIntervalMins)
        }
    }
    
    private func handleNextButtonTap() {
        // Save current page data
        saveCurrentPageData()
        
        if currentPage < totalPages - 1 {
            isMovingForward = true
            currentPage += 1
        } else {
            // Final page - save all data and complete onboarding
            saveAllGoals()
            hasCompletedOnboarding = true
            showNextScreen = true
        }
    }
    
    private func saveCurrentPageData() {
        switch currentPage {
        case 0:
            stepsGoal = selectedSteps
        case 1:
            waterGoalML = selectedWater
        case 2:
            sleepGoalMins = selectedSleep.totalMinutes
        case 3:
            breakIntervalMins = selectedBreakInterval.totalMinutes
        default:
            break
        }
    }
    
    private func saveAllGoals() {
        stepsGoal = selectedSteps
        waterGoalML = selectedWater
        sleepGoalMins = selectedSleep.totalMinutes
        breakIntervalMins = selectedBreakInterval.totalMinutes
    }
}

struct OnBoarding_Previews: PreviewProvider {
    static var previews: some View {
        OnBoarding()
    }
}

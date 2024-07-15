//
//  StartExerciseView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 14/7/24.
//

import SwiftUI

struct BreakScreenView: View {
    @State private var currentExerciseIndex: Int = 0
    @State private var elapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    @State private var buttonText: String = "Start Now"
    
    @Environment(\.presentationMode) var presentationMode

    let exercises: [ExerciseTest] = [
        ExerciseTest(name: "Pulse Lunges", duration: 30, description: "Do pulse lunges for 30 seconds per side."),
        ExerciseTest(name: "Power Skips", duration: 45, description: "Do power skips for 45 seconds."),
        ExerciseTest(name: "Single Legged Romanian Deadlifts", duration: 45, description: "Do single legged Romanian deadlifts for 45 seconds."),
        ExerciseTest(name: "Walk", duration: 60, description: "Walk for 60 seconds.")
    ]
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(timeString(from: elapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(.top, 20)
            
            Spacer()
            
            Text(exercises[currentExerciseIndex].name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text(exercises[currentExerciseIndex].description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            Text("\(exercises[currentExerciseIndex].duration) sec")
                .font(.subheadline)
                .padding(.bottom, 20)
            
            Spacer()
            
            Button(action: {
                if timerRunning {
                    // If "End Now" is clicked, navigate back
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // If "Start Now" is clicked, start the timer
                    timerRunning.toggle()
                    buttonText = "End Now"
                }
            }) {
                Text(buttonText)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            
            if elapsedTime < exercises[currentExerciseIndex].duration {
                elapsedTime += 1
            } else {
                // Move to the next exercise or finish
                if currentExerciseIndex < exercises.count - 1 {
                    currentExerciseIndex += 1
                    elapsedTime = 0
                } else {
                    // Timer has finished
                    timerRunning = false
                    buttonText = "Start Now"
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct BreakScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BreakScreenView()
    }
}

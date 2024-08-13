//
//  StartExerciseView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 14/7/24.
//

import SwiftUI
import AVFoundation

class SoundManager {
    static let instance = SoundManager()
    var player : AVAudioPlayer?
    
    func nextExerciseBeep() {
        guard let url = Bundle.main.url(forResource: "single_beep", withExtension: ".mp3")
        else {
            return
        }
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
    
    func allExerciseFinishBeep() {
        guard let url = Bundle.main.url(forResource: "count_down", withExtension: ".mp3")
        else {
            return
        }
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
}

struct StartExerciseView: View {
    @State private var currentExerciseIndex: Int = 0
    @State private var elapsedTime: Int = 0
    @State private var totalElapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    @State private var buttonText: String = "Start Now"
    
    let exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode
    
    // Total duration of all exercises
    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(timeString(from: totalElapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(.top, 20)
            
            Spacer()
            
            Text(exercises[currentExerciseIndex].name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            
            Text(exercises[currentExerciseIndex].description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            Text("\(remainingTime(for: exercises[currentExerciseIndex])) sec")
                .font(.subheadline)
                .padding(.bottom, 20)
                .bold()
            
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
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            
            if totalElapsedTime < totalDuration {
                totalElapsedTime += 1
                
                if elapsedTime < exercises[currentExerciseIndex].duration {
                    elapsedTime += 1
                } else {
                    // Move to the next exercise or finish
                    if currentExerciseIndex < exercises.count - 1 {
                        currentExerciseIndex += 1
                        elapsedTime = 0
                        SoundManager.instance.nextExerciseBeep() // Single beep when each exercise ends
                    }
                }
            } else {
                // Total duration has completed
                SoundManager.instance.allExerciseFinishBeep() // Double beep when all exercises are complete
                timerRunning = false
                buttonText = "Start Now"
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func remainingTime(for exercise: Exercise) -> Int {
        return exercise.duration - elapsedTime
    }

    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct BreakScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let sets: [Exercise] = [
            // quick exercise
            Exercise(name: "Neck Rolls", description: "Gently roll your neck in a circular motion.", duration: 15),
            Exercise(name: "Shoulder Shrugs", description: "Raise your shoulders towards your ears, then lower them.", duration: 15)
        ]
        
        StartExerciseView(exercises: sets)
    }
}

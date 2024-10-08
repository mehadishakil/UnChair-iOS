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
    var player: AVAudioPlayer?

    func nextExerciseBeep() {
        guard let url = Bundle.main.url(forResource: "single_beep", withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func allExerciseFinishBeep() {
        guard let url = Bundle.main.url(forResource: "count_down", withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

struct StartExerciseView: View {
    @State private var currentExerciseIndex: Int = 0
    @State private var elapsedTime: Int = 0
    @State private var totalElapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    @State private var showControlButtons: Bool = false
    @State private var isPaused: Bool = false
    
    let exercises: [Exercise]
    @Environment(\.presentationMode) var presentationMode

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

            Image(exercises[currentExerciseIndex].image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                

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

            if showControlButtons {
                HStack(spacing: 20) {
                    Button(action: resetExercise) {
                        Text("Reset")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(.secondary)
                            .cornerRadius(25)
                    }

                    Button(action: {
                        isPaused.toggle()
                        timerRunning.toggle()
                    }) {
                        Text(isPaused ? "Resume" : "Pause")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(.secondary)
                            .cornerRadius(25)
                    }
                }
            } else {
                Button(action: startExercise) {
                    Text("Start Now")
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(.primary)
                        .cornerRadius(25)
                }
            }
        }
        .padding(.bottom, 40)
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            updateTimer()
        }
    }

    private func startExercise() {
        timerRunning = true
        showControlButtons = true
    }

    private func resetExercise() {
        timerRunning = false
        showControlButtons = false
        isPaused = false
        totalElapsedTime = 0
        elapsedTime = 0
        currentExerciseIndex = 0
    }

    private func updateTimer() {
        if totalElapsedTime < totalDuration {
            totalElapsedTime += 1

            if elapsedTime < exercises[currentExerciseIndex].duration {
                elapsedTime += 1
            } else {
                if currentExerciseIndex < exercises.count - 1 {
                    currentExerciseIndex += 1
                    elapsedTime = 0
                    SoundManager.instance.nextExerciseBeep()
                }
            }
        } else {
            SoundManager.instance.allExerciseFinishBeep()
            resetExercise()
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func remainingTime(for exercise: Exercise) -> Int {
        return exercise.duration - elapsedTime
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct BreakScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let sets: [Exercise] = [
            Exercise(image: "neck_rolls", name: "Neck Rolls", description: "Gently roll your neck in a circular motion.", duration: 15),
            Exercise(image: "neck_rolls", name: "Shoulder Shrugs", description: "Raise your shoulders towards your ears, then lower them.", duration: 15)
        ]
        StartExerciseView(exercises: sets)
    }
}

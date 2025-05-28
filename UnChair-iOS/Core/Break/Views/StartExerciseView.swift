//
//  StartExerciseView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 14/7/24.
//

import SwiftUI
import AVFoundation
import FirebaseAuth

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    func nextExerciseBeep() {
        guard let url = Bundle.main.url(forResource: "single_beep", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func allExerciseFinishBeep() {
        guard let url = Bundle.main.url(forResource: "count_down", withExtension: "mp3") else { return }
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
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    let breakItem: Break
    var exercises: [Exercise] { breakItem.exercises }
    private var progressValue: Double {
        let duration = Double(exercises[currentExerciseIndex].duration)
        let remaining = Double(remainingTime(for: exercises[currentExerciseIndex]))
        return remaining / duration // ProgressView goes from 0 (start) to 1 (end)
    }
    
    
    @Environment(\.dismiss) private var dismiss
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let mainButtonSize: CGFloat = 60
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundColor(.primary)
                    Text("\(timeString(from: totalDuration - totalElapsedTime))")
                        .font(.callout.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                
                ZStack {
                    // Outer Circle – Overall Progress
                    Circle()
                        .stroke(lineWidth: 16)
                        .opacity(0.2)
                        .foregroundColor(.blue)
                        .frame(width: 300, height: 300)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(Double(totalElapsedTime) / Double(totalDuration)))
                        .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 0.2), value: totalElapsedTime)
                        .frame(width: 300, height: 300)
                    
                    // Inner Circle – Current Exercise Progress
                    Circle()
                        .fill(.gray.opacity(1.9))
                        .stroke(Color.blue.secondary, lineWidth: 4)
                        .foregroundColor(.green.opacity(0.5))
                        .frame(width: 276, height: 276)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(Double(elapsedTime) / Double(exercises[currentExerciseIndex].duration)))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue.opacity(0.7))
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 0.2), value: elapsedTime)
                        .frame(width: 276, height: 276)
                    
                    Image(exercises[currentExerciseIndex].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                    
                }
                .padding(.vertical, 30)
                
                
                Spacer()
                
                VStack(spacing: 4){
                    Text("\(currentExerciseIndex + 1) of \(exercises.count) sessions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    
                    Text(exercises[currentExerciseIndex].name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(exercises[currentExerciseIndex].description)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 4)
                
                Spacer()
                
                ZStack {
                    Rectangle()
                        .mask(liquidButtonCanvas)
                        .overlay {
                            ZStack {
                                // Reset Icon
                                LiquidButtonIcon(
                                    show: $showControlButtons,
                                    icon: "arrow.clockwise",
                                    xOffset: -100,
                                    animationDelay: 0.12,
                                    action: {
                                        resetExercise()
                                    })
                                
                                // Pause/Resume Icon
                                LiquidButtonIcon(
                                    show: $showControlButtons,
                                    icon: isPaused ? "play.fill" : "pause.fill",
                                    xOffset: 100,
                                    animationDelay: 0.08,
                                    action: {
                                        timerRunning.toggle()
                                        isPaused.toggle()
                                    })
                                
                                // Main Action Button
                                Button {
                                    if timerRunning {
                                        // STOP
                                        timerRunning = false
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                                            showControlButtons = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            finishExercise()
                                        }
                                    } else {
                                        // START
                                        timerRunning = true
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                                            showControlButtons.toggle()
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .frame(width: 60)
                                            .foregroundColor(timerRunning ? .red : .blue)
                                        Text(timerRunning ? "Stop" : "Start")
                                            .font(.callout.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                }
                .frame(height: 70)
                .padding(.bottom, 40)
                
                Spacer()
            }
            .onReceive(timer) { _ in
                guard timerRunning else { return }
                updateTimer()
            }
        }
    }
    
    // MARK: - Liquid Button Canvas
    private var liquidButtonCanvas: some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.4))
            context.addFilter(.blur(radius: 12))
            context.drawLayer { drawingContext in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                for id in 1...4 {
                    if let sym = context.resolveSymbol(id: id) {
                        drawingContext.draw(sym, at: center)
                    }
                }
            }
        } symbols: {
            Circle()
                .frame(width: 52)
                .tag(1)
            
            Circle()
                .frame(width: 52)
                .tag(2)
                .offset(x: showControlButtons ? -100 : 0)
                .animation(.spring(response: 1, dampingFraction: 0.8).delay(showControlButtons ? 0.12 : 0.08), value: showControlButtons)
            
            Circle()
                .frame(width: 52)
                .tag(3)
                .offset(x: showControlButtons ? 100 : 0)
                .animation(.spring(response: 1, dampingFraction: 1).delay(showControlButtons ? 0.08 : 0.12), value: showControlButtons)
            
            Circle()
                .frame(width: 100)
                .tag(4)
                .opacity(0.6)
        }
    }
    
    struct LiquidButtonIcon: View {
        @Binding var show: Bool
        let icon: String
        var xOffset: CGFloat
        var animationDelay: Double
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white.opacity(0.2))
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: show ? xOffset : 0)
            .scaleEffect(show ? 1 : 0)
            .opacity(show ? 1 : 0)
            .animation(.spring(response: 1, dampingFraction: 0.8)
                .delay(show ? animationDelay : animationDelay/2),
                       value: show)
        }
    }
    
    // MARK: - Timer & Exercise Logic
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
            } else if currentExerciseIndex < exercises.count - 1 {
                currentExerciseIndex += 1
                elapsedTime = 0
                SoundManager.instance.nextExerciseBeep()
            }
        } else {
            SoundManager.instance.allExerciseFinishBeep()
            finishExercise()
        }
    }
    
    private func finishExercise() {
        // Save last break time
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastBreakTime")
        UserDefaults.standard.set(Calendar.current.dateComponents([.year, .month, .day], from: Date()).day,
                                  forKey: "lastBreakDay")
        
        updateExerciseRecord()
        resetExercise()
        dismiss()
    }
    
    private func updateExerciseRecord() {
        guard let user = Auth.auth().currentUser else { return }
        let exerciseMinutes = totalDuration / 60
        let breakKey = breakItem.title.lowercased().replacingOccurrences(of: " ", with: "_")
        let service = HealthDataService()
        Task {
            do {
                var data = try await service.fetchTodaysExerciseData(for: user.uid, date: Date()) ?? [:]
                let current = data[breakKey] ?? 0
                data[breakKey] = current + exerciseMinutes
                try await service.updateDailyHealthData(
                    for: user.uid,
                    date: Date(),
                    waterIntake: nil,
                    stepsTaken: nil,
                    sleepDuration: nil,
                    meditationDuration: nil,
                    exerciseTime: data)
            } catch {
                print("Failed to update exercise record: \(error.localizedDescription)")
            }
        }
    }
    
    private func remainingTime(for exercise: Exercise) -> Int {
        return exercise.duration - elapsedTime
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - Preview
struct StartExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        let dummy = Break(
            title: "Quick Break",
            image: "neck_rolls",
            overview: "A quick break to relieve tension",
            description: "A quick session focusing on neck and shoulder stretches.",
            duration: 30,
            exercises: [
                Exercise(image: "neck_rolls", name: "Neck Rolls", description: "Gently roll your neck in a circular motion.", duration: 15),
                Exercise(image: "neck_rolls", name: "Shoulder Shrugs", description: "Raise your shoulders towards your ears, then lower them.", duration: 15)
            ]
        )
        StartExerciseView(breakItem: dummy)
    }
}

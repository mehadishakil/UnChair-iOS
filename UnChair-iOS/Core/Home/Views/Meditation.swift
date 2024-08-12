//
//  Meditation.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.
//

import SwiftUI

struct Meditation: View {
    @State private var progress: Float = 0.0
    @State private var remainingTime: Int = 15 * 60 // 15 minutes in seconds
    @State private var timer: Timer? = nil
    @State private var meditationTime: Int = 15
    @State private var totalTime: Int = 15 * 60 // Total time in seconds
    @State private var isRunning: Bool = false
    @State private var isPaused: Bool = false
    @State private var startTime: Date = Date()
    @State private var timeRangeText: String = ""
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("\(meditationTime) min activity")
                .font(.headline)
            Text(timeRangeText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.purple)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.purple)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                VStack {
                    Text(timeString(time: remainingTime))
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                }
            }
            .frame(width: 250, height: 250)
            
            HStack(alignment: .center ,spacing: 2){
                ForEach([1, 3, 5], id: \.self) { minutes in
                    Button(action: {
                        addTime(minutes: minutes)
                    }) {
                        Text("+\(minutes) min")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(meditationTime >= 60)
                }
            }
            .padding(.vertical, 20)
            
            if isRunning {
                
                
                HStack(alignment: .center,spacing: 10){
                    Button(action: {
                        resetTimer()
                    }) {
                        Text("Reset")
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        togglePause()
                    }) {
                        Text(isPaused ? "Resume" : "Pause")
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(isPaused ? Color.green : Color.purple.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            } else {
                Button(action: {
                    startTimer()
                    updateTimeRange()
                }) {
                    Text("Start")
                        .fontWeight(.bold)
                        .padding(.horizontal, 100)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear(perform: updateTimeRange)
    }
    
    func startTimer() {
        isRunning = true
        startTime = Date()
        updateTimeRange()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                self.progress = Float(totalTime - self.remainingTime) / Float(totalTime)
            } else {
                self.timer?.invalidate()
                self.isRunning = false
            }
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        remainingTime = 15 * 60
        meditationTime = 15
        totalTime = 15 * 60
        progress = 0.0
        isRunning = false
        isPaused = false
        updateTimeRange()
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            startTimer()
        }
    }
    
    func addTime(minutes: Int) {
        let newMeditationTime = min(meditationTime + minutes, 60)
        let timeToAdd = (newMeditationTime - meditationTime) * 60
        
        meditationTime = newMeditationTime
        
        if meditationTime == 60 {
            remainingTime = 60 * 60
            totalTime = 60 * 60
        } else {
            remainingTime += timeToAdd
            totalTime += timeToAdd
        }
        
        progress = Float(totalTime - remainingTime) / Float(totalTime)
        updateTimeRange()
    }
    
    func updateTimeRange() {
        let currentTime : Date = Date()
        let endTime = Calendar.current.date(byAdding: .second, value: totalTime, to: currentTime) ?? currentTime
        timeRangeText = "\(timeFormatter.string(from: currentTime)) - \(timeFormatter.string(from: endTime))"
    }
    
    func timeString(time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%2i:%02i", minutes, seconds)
    }
}

#Preview {
    Meditation()
}

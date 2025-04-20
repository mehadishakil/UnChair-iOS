//
//  Meditation.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.
//
// Meditation.swift
import SwiftUI

struct Meditation: View {
  @EnvironmentObject var healthVM: HealthDataViewModel

  // now injected
  let initialTime: Int

  // initialize state from that
  @State private var meditationTime: Int
  @State private var totalTime: Int
  @State private var remainingTime: Int

  @State private var progress: Float = 0
  @State private var timer: Timer? = nil
  @State private var isRunning = false
  @State private var isPaused = false
  @State private var timeRangeText = ""

  let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.timeStyle = .short
    return f
  }()

  init(initialTime: Int) {
    self.initialTime = initialTime
    // hack to seed @State once
    _meditationTime = State(initialValue: initialTime)
    _totalTime      = State(initialValue: initialTime * 60)
    _remainingTime  = State(initialValue: initialTime * 60)
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("\(meditationTime) min session")
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
          .trim(from: 0, to: CGFloat(min(progress,1)))
          .stroke(style: .init(lineWidth: 20, lineCap: .round))
          .foregroundColor(.purple)
          .rotationEffect(.degrees(270))
          .animation(.linear, value: progress)
        Text(timeString(remainingTime))
          .font(.system(size: 50, weight: .bold, design: .rounded))
      }
      .frame(width: 250, height: 250)

      if isRunning {
        HStack(spacing: 20) {
          Button("Reset") { resetTimer() }
            .padding(.horizontal,40)
            .padding(.vertical,10)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)

          Button(isPaused ? "Resume" : "Pause") { togglePause() }
            .padding(.horizontal,40)
            .padding(.vertical,10)
            .background(isPaused ? Color.green : Color.purple.opacity(0.85))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      } else {
        Button("Start") {
          startTimer()
          updateTimeRange()
        }
        .fontWeight(.bold)
        .padding(.horizontal,100)
        .padding(.vertical,10)
        .background(Color.purple.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(10)
      }
    }
    .onAppear(perform: updateTimeRange)
  }

  // MARK: Timer

  func startTimer() {
    isRunning = true
    updateTimeRange()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      if remainingTime > 0 {
        remainingTime -= 1
        progress = Float(totalTime - remainingTime)/Float(totalTime)
      } else {
        timer?.invalidate()
        isRunning = false
        healthVM.updateMeditationDuration(meditationTime)
      }
    }
  }

  func resetTimer() {
    timer?.invalidate()
    meditationTime = initialTime
    totalTime      = initialTime * 60
    remainingTime  = initialTime * 60
    progress       = 0
    isRunning      = false
    isPaused       = false
    updateTimeRange()
  }

  func togglePause() {
    isPaused.toggle()
    if isPaused { timer?.invalidate() }
    else        { startTimer() }
  }

  // MARK: Helpers

  func updateTimeRange() {
    let now = Date()
    let end = Calendar.current.date(
      byAdding: .second,
      value: totalTime,
      to: now
    ) ?? now
    timeRangeText = "\(timeFormatter.string(from:now)) – \(timeFormatter.string(from:end))"
  }

  func timeString(_ sec: Int) -> String {
    let m = (sec/60)%60, s = sec%60
    return String(format: "%2d:%02d", m, s)
  }
}

#Preview {
    Meditation(initialTime: 5)
      .environmentObject(HealthDataViewModel())
}

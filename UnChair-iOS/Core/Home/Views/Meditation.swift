//  Meditation.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 11/8/24.

import SwiftUI

struct Meditation: View {
    @EnvironmentObject var healthVM: HealthDataViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var meditationTime: Int
    @State private var totalTime: Int
    @State private var remainingTime: Int
    @State private var progress: Float = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var timeRangeText = ""
    @State private var showControls = false
    let initialTime: Int

    let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    init(initialTime: Int) {
        self.initialTime = initialTime
        // seed @State
        _meditationTime = State(initialValue: initialTime)
        _totalTime      = State(initialValue: initialTime * 60)
        _remainingTime  = State(initialValue: initialTime * 60)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Session: \(meditationTime) min")
                .font(.title2.bold())
            Text("Relax and take deep breaths")
                .font(.footnote)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.blue.opacity(0.8))
                    .padding()
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress,1)))
                    .stroke(style: .init(lineWidth: 20, lineCap: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(270))
                    .animation(.linear, value: progress)
                    .padding()
                Text(timeString(remainingTime))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
            }
            .padding()

            // Liquid Button Controls
            ZStack {
                Rectangle()
                    .mask(liquidButtonCanvas)
                    .overlay {
                        ZStack {
                            // Reset Icon (Left)
                            LiquidButtonIcon(
                                show: $showControls,
                                icon: "arrow.clockwise",
                                xOffset: -100,
                                yOffset: 0,
                                animationDelay: 0.12,
                                action: { resetTimer() }
                            )
                            
                            // Pause/Resume (Right)
                            LiquidButtonIcon(
                                show: $showControls,
                                icon: isPaused ? "play.fill" : "stop.fill",
                                xOffset: 100,
                                yOffset: 0,
                                animationDelay: 0.08,
                                action: { togglePause() }
                            )
                            
                            // Main Action Button
                            Button {
                                if isRunning {
                                    // user hit Stop → save only full minutes
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                                        showControls = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        savePartialSessionAndDismiss()
                                    }
                                } else {
                                    startTimer()
                                    updateTimeRange()
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                                        showControls = true
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 60)
                                        .foregroundColor(isRunning ? .red : .blue)
                                    Text(isRunning ? "Stop" : "Start")
                                        .font(.callout.bold())
                                        .foregroundColor(.white)
                                }
                            }

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            }
            .frame(height: 70)
        }
        .onAppear(perform: updateTimeRange)
    }

    // MARK: Liquid Button Canvas
    var liquidButtonCanvas: some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.4))
            context.addFilter(.blur(radius: 12))
            context.drawLayer { drawingContext in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                for id in 1...4 {
                    if let symbol = context.resolveSymbol(id: id) {
                        drawingContext.draw(symbol, at: center)
                    }
                }
            }
        } symbols: {
            Circle().frame(width: 52).tag(1)
            Circle().frame(width: 52).tag(2)
                .offset(x: showControls ? -100 : 0)
                .animation(.spring(response: 1, dampingFraction: 0.8).delay(showControls ? 0.12 : 0.08), value: showControls)
            Circle().frame(width: 52).tag(3)
                .offset(x: showControls ? 100 : 0)
                .animation(.spring(response: 1, dampingFraction: 0.8).delay(showControls ? 0.08 : 0.12), value: showControls)
            Circle().frame(width: 100).tag(4).opacity(0.6)
        }
    }

    // MARK: Timer
    func startTimer() {
        isRunning = true
        updateTimeRange()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard remainingTime > 0 else {
                finishSession()
                return
            }
            remainingTime -= 1
            progress = Float(totalTime - remainingTime) / Float(totalTime)
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
        showControls   = false
        updateTimeRange()
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused { timer?.invalidate() }
        else { startTimer() }
    }

    private func finishSession() {
        savePartialSessionAndDismiss()
    }

    /// Computes full minutes, updates storage, then dismisses
    private func savePartialSessionAndDismiss() {
        timer?.invalidate()
        isRunning = false
        let secondsElapsed = totalTime - remainingTime
        let performedMinutes = secondsElapsed / 60
        if performedMinutes > 0 {
            healthVM.updateMeditationDuration(performedMinutes)
        }
        dismiss()
    }

    func updateTimeRange() {
        let now = Date()
        let end = Calendar.current.date(byAdding: .second, value: totalTime, to: now) ?? now
        timeRangeText = "\(timeFormatter.string(from: now)) – \(timeFormatter.string(from: end))"
    }

    func timeString(_ sec: Int) -> String {
        let m = (sec/60)%60, s = sec%60
        return String(format: "%2d:%02d", m, s)
    }
}

struct LiquidButtonIcon: View {
    @Binding var show: Bool
    let icon: String
    var xOffset: CGFloat
    var yOffset: CGFloat
    var animationDelay: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().frame(width: 60).foregroundColor(.white.opacity(0.2))
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(x: show ? xOffset : 0, y: show ? yOffset : 0)
        .scaleEffect(show ? 1 : 0)
        .opacity(show ? 1 : 0)
        .animation(.spring(response: 1, dampingFraction: 0.8)
            .delay(show ? animationDelay : animationDelay / 2),
            value: show)
    }
}

#Preview {
    Meditation(initialTime: 5)
        .environmentObject(HealthDataViewModel())
}

//
//  SedentaryTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/24.
//

import SwiftUI
import Foundation

struct SedentaryTime: View {
    @StateObject private var settings = SettingsManager.shared
    @Binding var notificationPermissionGranted: Bool
    @Binding var selectedDuration: TimeDuration
    @State private var timeElapsed: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let onTakeBreak: () -> Void
    
    init(notificationPermissionGranted: Binding<Bool>, selectedDuration: Binding<TimeDuration>, onTakeBreak: @escaping () -> Void) {
        self._notificationPermissionGranted = notificationPermissionGranted
        self._selectedDuration = selectedDuration
        self.onTakeBreak = onTakeBreak
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
            
            HStack() {
                Spacer()
                
                Image(systemName: "hourglass.tophalf.filled")
                    .resizable()
                    .frame(width: 90, height: 120)
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Sedentary Time")
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    Text("\(formattedTime(timeElapsed))")
                        .font(.title3)
                        .foregroundColor(.primary)
                    Button {
                        onTakeBreak()
                    } label: {
                        Text("Unchair")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.blue)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)


                }
                Spacer()
            }
            .padding()
            .onAppear {
                NotificationManager.shared.checkAndResetLastBreakTimeIfNeeded()
                updateTimeElapsed()
                
                NotificationCenter.default.addObserver(
                    forName: .breakNotificationTapped,
                    object: nil,
                    queue: .main
                ) { _ in
                    updateTimeElapsed()
                }
                
                NotificationCenter.default.addObserver(
                    forName: .breakSettingsChanged,
                    object: nil,
                    queue: .main
                ) { _ in
                    NotificationManager.shared.scheduleNextBreakNotification()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
            .onReceive(timer) { _ in
                updateTimeElapsed()
            }

        }
            .frame(height: 170)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    
    private func updateTimeElapsed() {
        let now = Date()
        
        if isWithinActiveHours(now) {
            let lastBreakTime = NotificationManager.shared.getLastBreakTime() ?? getActiveHourStartForToday()
            
            let elapsed = Int(now.timeIntervalSince(lastBreakTime))
            timeElapsed = max(elapsed, 0)
            
            if notificationPermissionGranted &&
               timeElapsed >= (selectedDuration.totalMinutes * 60) &&
               !NotificationManager.shared.hasScheduledNotification() {
                NotificationManager.shared.scheduleNextBreakNotification()
            }
        } else {
            timeElapsed = 0
        }
    }
    
    private func isWithinActiveHours(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: date)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!
        
        // Get start/end times for today
        let startComps = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        let endComps = calendar.dateComponents([.hour, .minute], from: settings.endTime)
        let startSecs = (startComps.hour! * 3600) + (startComps.minute! * 60)
        let endSecs = (endComps.hour! * 3600) + (endComps.minute! * 60)
        
        if startSecs <= endSecs {
            // No midnight wrap
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            // Wraps past midnight
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }
    
    private func getActiveHourStartForToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: settings.startTime)
        
        // Combine today's date with start time
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = startTimeComponents.hour
        components.minute = startTimeComponents.minute
        
        return calendar.date(from: components) ?? now
    }
}

func formattedTime(_ totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let min = (totalSeconds % 3600) / 60
    let sec = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, min, sec)
}

#Preview {
    SedentaryTime(notificationPermissionGranted: .constant(true), selectedDuration: .constant(.init(hours: 2, minutes: 2))) {
        
    }
}

//
//  SedentaryActivityAttributes.swift
//  UnChair-iOS
//
//  Live Activity attributes for sedentary time tracking
//

import ActivityKit
import Foundation
import SwiftUI

struct SedentaryActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during the Live Activity
        var sessionStartTime: Date      // When tracking started
        var breakIntervalSeconds: TimeInterval
        var isOnBreak: Bool
        var breakDurationSeconds: TimeInterval  // Duration of the break
        var breakEndTime: Date?  // When the break should end

        init(sessionStartTime: Date, breakIntervalSeconds: TimeInterval, isOnBreak: Bool = false, breakDurationSeconds: TimeInterval = 0, breakEndTime: Date? = nil) {
            self.sessionStartTime = sessionStartTime
            self.breakIntervalSeconds = breakIntervalSeconds
            self.isOnBreak = isOnBreak
            self.breakDurationSeconds = breakDurationSeconds
            self.breakEndTime = breakEndTime
        }

        // MARK: - Computed Properties

        /// Calculated elapsed time from session start
        var elapsedTime: TimeInterval {
            Date().timeIntervalSince(sessionStartTime)
        }

        /// Progress percentage (0.0 to >1.0 if over limit)
        var progressPercentage: Double {
            guard breakIntervalSeconds > 0 else { return 0 }
            return elapsedTime / breakIntervalSeconds
        }

        /// Time remaining until break (can be negative if over limit)
        var timeRemaining: TimeInterval {
            breakIntervalSeconds - elapsedTime
        }

        /// Color state based on progress thresholds
        var colorState: ColorState {
            let percentage = progressPercentage
            if percentage >= 1.0 {
                return .red      // Over limit (100%+)
            } else if percentage >= 0.8 {
                return .orange   // Warning zone (80-100%)
            } else {
                return .green    // Safe zone (0-80%)
            }
        }

        // MARK: - Formatted Strings

        /// Formatted elapsed time (HH:MM:SS)
        var formattedElapsedTime: String {
            formatTime(elapsedTime)
        }

        /// Formatted time remaining or over limit
        var formattedTimeRemaining: String {
            if timeRemaining >= 0 {
                return formatTime(timeRemaining)
            } else {
                return "Over by \(formatTime(abs(timeRemaining)))"
            }
        }

        /// Short formatted elapsed time (MM:SS)
        var shortFormattedElapsedTime: String {
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        /// Progress percentage as string
        var formattedProgress: String {
            let percentage = min(progressPercentage * 100, 999)
            return String(format: "%.0f%%", percentage)
        }

        // MARK: - Break Mode Properties

        /// Time remaining in break
        var breakTimeRemaining: TimeInterval {
            guard let endTime = breakEndTime else { return 0 }
            return max(0, endTime.timeIntervalSinceNow)
        }

        /// Formatted break time remaining
        var formattedBreakTimeRemaining: String {
            formatTime(breakTimeRemaining)
        }

        /// Break progress (0.0 to 1.0)
        var breakProgress: Double {
            guard breakDurationSeconds > 0 else { return 0 }
            let elapsed = breakDurationSeconds - breakTimeRemaining
            return min(elapsed / breakDurationSeconds, 1.0)
        }

        /// Is break finished
        var isBreakFinished: Bool {
            breakTimeRemaining <= 0
        }

        // MARK: - Helper Methods

        private func formatTime(_ seconds: TimeInterval) -> String {
            let hours = Int(seconds) / 3600
            let minutes = (Int(seconds) % 3600) / 60

            // Format as HH:MM without seconds for Live Activity
            return String(format: "%02d:%02d", hours, minutes)
        }

        // MARK: - Color State Enum

        enum ColorState: Codable, Hashable {
            case green, orange, red

            var backgroundColor: Color {
                switch self {
                case .green:
                    return Color.green.opacity(0.12)
                case .orange:
                    return Color.orange.opacity(0.15)
                case .red:
                    return Color.red.opacity(0.18)
                }
            }

            var accentColor: Color {
                switch self {
                case .green:
                    return Color(red: 0.2, green: 0.78, blue: 0.35) // Brighter green
                case .orange:
                    return Color(red: 1.0, green: 0.58, blue: 0.0) // Brighter orange
                case .red:
                    return Color(red: 1.0, green: 0.23, blue: 0.19) // Brighter red
                }
            }

            var progressColor: Color {
                switch self {
                case .green:
                    return Color(red: 0.2, green: 0.78, blue: 0.35)
                case .orange:
                    return Color(red: 1.0, green: 0.58, blue: 0.0)
                case .red:
                    return Color(red: 1.0, green: 0.23, blue: 0.19)
                }
            }

            var statusText: String {
                switch self {
                case .green:
                    return "Active"
                case .orange:
                    return "Warning"
                case .red:
                    return "Over Limit"
                }
            }
        }
    }

    // Static attributes (don't change during activity)
    var workStartTime: Date
    var workEndTime: Date
    var userName: String

    init(workStartTime: Date, workEndTime: Date, userName: String = "User") {
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.userName = userName
    }
}

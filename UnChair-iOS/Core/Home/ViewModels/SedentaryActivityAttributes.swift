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

        init(sessionStartTime: Date, breakIntervalSeconds: TimeInterval, isOnBreak: Bool = false) {
            self.sessionStartTime = sessionStartTime
            self.breakIntervalSeconds = breakIntervalSeconds
            self.isOnBreak = isOnBreak
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

        // MARK: - Helper Methods

        private func formatTime(_ seconds: TimeInterval) -> String {
            let hours = Int(seconds) / 3600
            let minutes = (Int(seconds) % 3600) / 60
            let secs = Int(seconds) % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, secs)
            } else {
                return String(format: "%02d:%02d", minutes, secs)
            }
        }

        // MARK: - Color State Enum

        enum ColorState: Codable, Hashable {
            case green, orange, red

            var backgroundColor: Color {
                switch self {
                case .green:
                    return Color.green.opacity(0.2)
                case .orange:
                    return Color.orange.opacity(0.3)
                case .red:
                    return Color.red.opacity(0.4)
                }
            }

            var accentColor: Color {
                switch self {
                case .green:
                    return .green
                case .orange:
                    return .orange
                case .red:
                    return .red
                }
            }

            var progressColor: Color {
                switch self {
                case .green:
                    return Color.green
                case .orange:
                    return Color.orange
                case .red:
                    return Color.red
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

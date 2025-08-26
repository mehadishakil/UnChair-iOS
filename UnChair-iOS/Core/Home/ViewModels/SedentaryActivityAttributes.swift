//
//  SedentaryActivityAttributes.swift
//  UnChair-iOS
//
//  Created by Claude Code on 24/8/25.
//

import ActivityKit
import Foundation

struct SedentaryActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during the Live Activity
        var sedentaryTime: TimeInterval
        var timeUntilNextBreak: TimeInterval
        var isOnBreak: Bool
        var lastBreakTime: Date?
        var breakCount: Int
        
        init(sedentaryTime: TimeInterval = 0, timeUntilNextBreak: TimeInterval = 0, isOnBreak: Bool = false, lastBreakTime: Date? = nil, breakCount: Int = 0) {
            self.sedentaryTime = sedentaryTime
            self.timeUntilNextBreak = timeUntilNextBreak
            self.isOnBreak = isOnBreak
            self.lastBreakTime = lastBreakTime
            self.breakCount = breakCount
        }
    }
    
    // Static data that doesn't change during the Live Activity
    var workStartTime: Date
    var workEndTime: Date
    var breakInterval: TimeInterval // Time between breaks in seconds
    var userName: String
    
    init(workStartTime: Date, workEndTime: Date, breakInterval: TimeInterval, userName: String = "User") {
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.breakInterval = breakInterval
        self.userName = userName
    }
}

extension SedentaryActivityAttributes {
    // Helper computed properties for the ContentState
    var contentState: ContentState {
        return ContentState()
    }
}

extension SedentaryActivityAttributes.ContentState {
    // Formatted strings for display
    var formattedSedentaryTime: String {
        let hours = Int(sedentaryTime) / 3600
        let minutes = Int(sedentaryTime) % 3600 / 60
        let seconds = Int(sedentaryTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formattedTimeUntilNextBreak: String {
        let minutes = Int(timeUntilNextBreak) / 60
        let seconds = Int(timeUntilNextBreak) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    func progressValue(breakInterval: TimeInterval) -> Double {
        // Calculate progress as a percentage (0.0 to 1.0)
        guard breakInterval > 0 else { return 0.0 }
        guard timeUntilNextBreak > 0 else { return 1.0 }
        let elapsed = breakInterval - timeUntilNextBreak
        return max(0.0, min(1.0, elapsed / breakInterval))
    }
}
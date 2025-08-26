//
//  TakeBreakIntent.swift
//  UnChair-iOS
//
//  Created by Claude Code on 24/8/25.
//

import Foundation
import AppIntents
import ActivityKit

struct TakeBreakIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Take Break"
    static var description = IntentDescription("Mark that you've taken a break from sitting")
    
    func perform() async throws -> some IntentResult {
        // Trigger break action in the main app
        await MainActor.run {
            BreakManager.shared.takeBreak()
        }
        
        return .result()
    }
}

// Extension to make the intent available to the Live Activity
extension TakeBreakIntent {
    static var openAppWhenRun: Bool = false
}
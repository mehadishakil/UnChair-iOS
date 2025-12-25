//
//  TakeBreakIntent.swift
//  UnChair-iOS
//
//  Intent for taking a break from the Live Activity
//

import Foundation
import AppIntents
import ActivityKit

struct TakeBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Take Break"
    static var description = IntentDescription("Mark that you've taken a break from sitting")

    // Open app when this intent runs
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Update break time in App Group storage
        let now = Date()
        AppGroupStorage.shared.lastBreakTime = now.timeIntervalSince1970

        // Update all active Live Activities
        for activity in Activity<SedentaryActivityAttributes>.activities {
            let newState = SedentaryActivityAttributes.ContentState(
                sessionStartTime: now,  // Reset to now
                breakIntervalSeconds: activity.content.state.breakIntervalSeconds,
                isOnBreak: false
            )

            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: nil
                )
            )
        }

        return .result()
    }
}

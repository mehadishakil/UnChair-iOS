//
//  SedentaryLiveActivityLiveActivity.swift
//  SedentaryLiveActivity
//
//  Live Activity UI for sedentary time tracking
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct SedentaryLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SedentaryActivityAttributes.self) { context in
            // MARK: - Lock Screen / Banner UI
            LockScreenLiveActivityView(context: context)
                .widgetURL(nil)
        } dynamicIsland: { context in
            // MARK: - Dynamic Island UI
            return DynamicIsland {
                // MARK: Expanded State
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        HStack(spacing: 6) {
                            Image(systemName: !isWithinWorkHours() ? "moon.fill" : (isActuallyOnBreak(context) ? "cup.and.saucer.fill" : "figure.walk"))
                                .foregroundColor(!isWithinWorkHours() ? .gray : context.state.colorState.accentColor)
                                .font(.title2)

                            Text(!isWithinWorkHours() ? "Closed" : (isActuallyOnBreak(context) ? "Break Time" : "Active Time"))
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if !isWithinWorkHours() {
                            // Outside work hours - show static 00:00
                            Text("closed")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)

                            Text("00:00")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .monospacedDigit()
                                .multilineTextAlignment(.trailing)
                        } else if isActuallyOnBreak(context), let breakEnd = context.state.breakEndTime {
                            Text("remaining")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)

                            Text(timerInterval: Date()...breakEnd, countsDown: true)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(context.state.colorState.accentColor)
                                .monospacedDigit()
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text("elapsed")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)

                            Text(context.state.sessionStartTime, style: .timer)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(context.state.colorState.accentColor)
                                .monospacedDigit()
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                DynamicIslandExpandedRegion(.center) {
                    // Empty - content is in leading and trailing
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        Text(!isWithinWorkHours() ? "Outside Hours" : (isActuallyOnBreak(context) ? "In Break" : "At Work"))
                            .font(.caption)
                            .foregroundColor(!isWithinWorkHours() ? .gray : context.state.colorState.accentColor)
                        Spacer()
                    }
                }

            } compactLeading: {
                Image(systemName: !isWithinWorkHours() ? "moon.fill" : (isActuallyOnBreak(context) ? "cup.and.saucer.fill" : "figure.walk"))
                    .foregroundColor(!isWithinWorkHours() ? .gray : context.state.colorState.accentColor)
                    .font(.system(size: 14))

            } compactTrailing: {
                if !isWithinWorkHours() {
                    // Outside work hours - show static 00:00
                    Text("00:00")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .monospacedDigit()
                } else if isActuallyOnBreak(context), let breakEnd = context.state.breakEndTime {
                    Text(timerInterval: Date()...breakEnd, countsDown: true)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                } else {
                    Text(context.state.sessionStartTime, style: .timer)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                }

            } minimal: {
                ZStack {
                    Circle()
                        .fill((!isWithinWorkHours() ? Color.gray : context.state.colorState.accentColor).opacity(0.3))
                        .frame(width: 24, height: 24)

                    Image(systemName: !isWithinWorkHours() ? "moon.fill" : (isActuallyOnBreak(context) ? "cup.and.saucer.fill" : "figure.walk"))
                        .font(.system(size: 12))
                        .foregroundColor(!isWithinWorkHours() ? .gray : context.state.colorState.accentColor)
                }
            }
            .keylineTint(context.state.colorState.accentColor)
        }
    }

    // Helper function to check if actually on break
    private func isActuallyOnBreak(_ context: ActivityViewContext<SedentaryActivityAttributes>) -> Bool {
        guard context.state.isOnBreak else { return false }
        guard let breakEnd = context.state.breakEndTime else { return false }
        return Date() < breakEnd
    }

    // Helper function to check if within work hours
    private func isWithinWorkHours() -> Bool {
        let storage = AppGroupStorage.shared
        let now = Date()
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let startSecs = (storage.workStartHour * 3600) + (storage.workStartMinute * 60)
        let endSecs = (storage.workEndHour * 3600) + (storage.workEndMinute * 60)

        if startSecs <= endSecs {
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>

    var body: some View {
        // Check if actually on break (break might have ended even if state says true)
        if isActuallyOnBreak(context) {
            BreakModeView(context: context)
        } else {
            WorkModeView(context: context, breakEndTime: context.state.breakEndTime)
        }
    }
    
    // Helper function to check if actually on break
    private func isActuallyOnBreak(_ context: ActivityViewContext<SedentaryActivityAttributes>) -> Bool {
        guard context.state.isOnBreak else { return false }
        guard let breakEnd = context.state.breakEndTime else { return false }
        return Date() < breakEnd
    }
}

// MARK: - Work Mode View

struct WorkModeView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>
    let breakEndTime: Date?

    // Calculate the correct session start time
    private var sessionStartTime: Date {
        // Check if we're transitioning from break to work (break just ended)
        if let breakEnd = breakEndTime,
           context.state.isOnBreak && Date() >= breakEnd {
            // Break has ended, count from break end time
            return breakEnd
        }
        // Otherwise use the session start from state
        return context.state.sessionStartTime
    }

    // Check if within work hours
    private var isWithinWorkHours: Bool {
        let storage = AppGroupStorage.shared
        let now = Date()
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let startSecs = (storage.workStartHour * 3600) + (storage.workStartMinute * 60)
        let endSecs = (storage.workEndHour * 3600) + (storage.workEndMinute * 60)

        if startSecs <= endSecs {
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: isWithinWorkHours ? "figure.walk" : "moon.fill")
                .foregroundColor(isWithinWorkHours ? context.state.colorState.accentColor : .gray)
                .font(.title)
                .frame(width: 44, height: 44)
                .background((isWithinWorkHours ? context.state.colorState.accentColor : Color.gray).opacity(0.15))
                .clipShape(Circle())

            // Time and Info
            VStack(alignment: .leading, spacing: 4) {
                Text(isWithinWorkHours ? "Active Time" : "Closed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                // Show timer only if within work hours, otherwise show 00:00
                if isWithinWorkHours {
                    Text(sessionStartTime, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                } else {
                    Text("00:00")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .monospacedDigit()
                }

                Text(isWithinWorkHours ? context.state.colorState.statusText : "Outside Hours")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Take Break Button - only if within work hours
            if isWithinWorkHours {
                Button(intent: TakeBreakIntent()) {
                    VStack(spacing: 4) {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Break")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(context.state.colorState.accentColor)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                // Show disabled/grayed out button outside hours
                VStack(spacing: 4) {
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Off")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.gray)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.15))
                .clipShape(Circle())
            }
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.01))
        .activitySystemActionForegroundColor(isWithinWorkHours ? context.state.colorState.accentColor : .gray)
    }
}

// MARK: - Break Mode View

struct BreakModeView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>

    // Check if within work hours
    private var isWithinWorkHours: Bool {
        let storage = AppGroupStorage.shared
        let now = Date()
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: now)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let startSecs = (storage.workStartHour * 3600) + (storage.workStartMinute * 60)
        let endSecs = (storage.workEndHour * 3600) + (storage.workEndMinute * 60)

        if startSecs <= endSecs {
            return currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            return currentSecs >= startSecs || currentSecs <= endSecs
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: isWithinWorkHours ? "cup.and.saucer.fill" : "moon.fill")
                .foregroundColor(isWithinWorkHours ? context.state.colorState.accentColor : .gray)
                .font(.title)
                .frame(width: 44, height: 44)
                .background((isWithinWorkHours ? context.state.colorState.accentColor : Color.gray).opacity(0.15))
                .clipShape(Circle())

            // Time and Info
            VStack(alignment: .leading, spacing: 4) {
                Text(isWithinWorkHours ? "Break Time" : "Closed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                // Auto-updating countdown timer - only if within work hours
                if isWithinWorkHours {
                    if let breakEnd = context.state.breakEndTime {
                        Text(timerInterval: Date()...breakEnd, countsDown: true)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(context.state.colorState.accentColor)
                            .monospacedDigit()
                    } else {
                        Text("00:00")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(context.state.colorState.accentColor)
                            .monospacedDigit()
                    }
                } else {
                    Text("00:00")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .monospacedDigit()
                }

                Text(isWithinWorkHours ? "Enjoy your break!" : "Outside Hours")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Icon indicator
            Image(systemName: isWithinWorkHours ? "sparkles" : "moon.zzz")
                .font(.title)
                .foregroundColor(isWithinWorkHours ? context.state.colorState.accentColor : .gray)
                .frame(width: 60, height: 60)
                .background((isWithinWorkHours ? context.state.colorState.accentColor : Color.gray).opacity(0.15))
                .clipShape(Circle())
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.01))
        .activitySystemActionForegroundColor(isWithinWorkHours ? context.state.colorState.accentColor : .gray)
    }
}

// MARK: - Previews

extension SedentaryActivityAttributes {
    fileprivate static var preview: SedentaryActivityAttributes {
        SedentaryActivityAttributes(
            workStartTime: Date(),
            workEndTime: Date().addingTimeInterval(8 * 3600),
            userName: "User"
        )
    }
}

extension SedentaryActivityAttributes.ContentState {
    // Green state (30% progress)
    fileprivate static var greenState: SedentaryActivityAttributes.ContentState {
        let now = Date()
        let sessionStart = now.addingTimeInterval(-18 * 60) // 18 minutes ago
        return SedentaryActivityAttributes.ContentState(
            sessionStartTime: sessionStart,
            breakIntervalSeconds: 60 * 60, // 60 minutes
            isOnBreak: false
        )
    }

    // Orange state (85% progress)
    fileprivate static var orangeState: SedentaryActivityAttributes.ContentState {
        let now = Date()
        let sessionStart = now.addingTimeInterval(-51 * 60) // 51 minutes ago
        return SedentaryActivityAttributes.ContentState(
            sessionStartTime: sessionStart,
            breakIntervalSeconds: 60 * 60, // 60 minutes
            isOnBreak: false
        )
    }

    // Red state (120% over limit)
    fileprivate static var redState: SedentaryActivityAttributes.ContentState {
        let now = Date()
        let sessionStart = now.addingTimeInterval(-72 * 60) // 72 minutes ago
        return SedentaryActivityAttributes.ContentState(
            sessionStartTime: sessionStart,
            breakIntervalSeconds: 60 * 60, // 60 minutes
            isOnBreak: false
        )
    }
}

#Preview("Green (Safe)", as: .content, using: SedentaryActivityAttributes.preview) {
    SedentaryLiveActivityLiveActivity()
} contentStates: {
    SedentaryActivityAttributes.ContentState.greenState
}

#Preview("Orange (Warning)", as: .content, using: SedentaryActivityAttributes.preview) {
    SedentaryLiveActivityLiveActivity()
} contentStates: {
    SedentaryActivityAttributes.ContentState.orangeState
}

#Preview("Red (Over Limit)", as: .content, using: SedentaryActivityAttributes.preview) {
    SedentaryLiveActivityLiveActivity()
} contentStates: {
    SedentaryActivityAttributes.ContentState.redState
}

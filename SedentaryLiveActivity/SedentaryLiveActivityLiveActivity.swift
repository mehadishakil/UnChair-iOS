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
            DynamicIsland {
                // MARK: Expanded State
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        
                        
                        HStack(spacing: 6) {
                            Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : "figure.walk")
                                .foregroundColor(context.state.isOnBreak ? .green : context.state.colorState.accentColor)
                                .font(.title2)
                            
                            Text(context.state.isOnBreak ? "Break Time" : "Active Time")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        // Auto-updating timer
                        if context.state.isOnBreak, let breakEnd = context.state.breakEndTime {
                            Text("remaining")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)

                            Text(timerInterval: Date()...breakEnd, countsDown: true)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
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
                    // Centered status text for both modes
                    HStack {
                        Spacer()
                        Text(context.state.isOnBreak ? "In Break" : "At Work")
                            .font(.caption)
                            .foregroundColor(context.state.isOnBreak ? .green : context.state.colorState.accentColor)
                        Spacer()
                    }
                }

            } compactLeading: {
                // MARK: Compact Leading
                Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : "figure.walk")
                    .foregroundColor(context.state.isOnBreak ? .green : context.state.colorState.accentColor)
                    .font(.system(size: 14))

            } compactTrailing: {
                // MARK: Compact Trailing
                // Auto-updating timer
                if context.state.isOnBreak, let breakEnd = context.state.breakEndTime {
                    Text(timerInterval: Date()...breakEnd, countsDown: true)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                        .monospacedDigit()
                } else {
                    Text(context.state.sessionStartTime, style: .timer)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                }

            } minimal: {
                // MARK: Minimal
                ZStack {
                    Circle()
                        .fill(context.state.colorState.accentColor.opacity(0.3))
                        .frame(width: 24, height: 24)

                    Image(systemName: "figure.walk")
                        .font(.system(size: 12))
                        .foregroundColor(context.state.colorState.accentColor)
                }
            }
            .keylineTint(context.state.colorState.accentColor)
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>

    var body: some View {
        if context.state.isOnBreak {
            // Break Mode UI
            BreakModeView(context: context)
        } else {
            // Work Mode UI
            WorkModeView(context: context)
        }
    }
}

// MARK: - Work Mode View

struct WorkModeView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "figure.walk")
                .foregroundColor(context.state.colorState.accentColor)
                .font(.title)
                .frame(width: 44, height: 44)
                .background(context.state.colorState.accentColor.opacity(0.15))
                .clipShape(Circle())

            // Time and Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Active Time")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                // Auto-updating timer
                Text(context.state.sessionStartTime, style: .timer)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(context.state.colorState.accentColor)
                    .monospacedDigit()

                Text(context.state.colorState.statusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Take Break Button
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
        }
        .padding(16)
        .activityBackgroundTint(context.state.colorState.backgroundColor)
        .activitySystemActionForegroundColor(context.state.colorState.accentColor)
    }
}

// MARK: - Break Mode View

struct BreakModeView: View {
    let context: ActivityViewContext<SedentaryActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.green)
                .font(.title)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.15))
                .clipShape(Circle())

            // Time and Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Break Time")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                // Auto-updating countdown timer
                if let breakEnd = context.state.breakEndTime {
                    Text(timerInterval: Date()...breakEnd, countsDown: true)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .monospacedDigit()
                } else {
                    Text("00:00")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .monospacedDigit()
                }

                Text("Enjoy your break!")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Icon indicator
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(.green)
                .frame(width: 60, height: 60)
                .background(Color.green.opacity(0.15))
                .clipShape(Circle())
        }
        .padding(16)
        .activityBackgroundTint(Color.green.opacity(0.1))
        .activitySystemActionForegroundColor(.green)
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

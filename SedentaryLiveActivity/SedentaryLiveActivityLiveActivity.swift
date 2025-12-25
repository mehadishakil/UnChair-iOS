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
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(context.state.colorState.accentColor)
                            .font(.title3)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.colorState.statusText)
                            .font(.caption2)
                            .foregroundColor(context.state.colorState.accentColor)

                        Text(context.state.formattedProgress)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("ACTIVE TIME")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .tracking(0.3)

                        Text(context.state.formattedElapsedTime)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(context.state.colorState.accentColor)
                            .monospacedDigit()
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 5)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                context.state.colorState.progressColor,
                                                context.state.colorState.progressColor.opacity(0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * min(context.state.progressPercentage, 1.0),
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)

                        // Time Remaining / Over Limit
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text("REMAINING")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .tracking(0.2)
                                Text(context.state.formattedTimeRemaining)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            // Take Break Button
                            Button(intent: TakeBreakIntent()) {
                                HStack(spacing: 4) {
                                    Image(systemName: "figure.stand")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text("Take Break")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            context.state.colorState.accentColor,
                                            context.state.colorState.accentColor.opacity(0.9)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                }

            } compactLeading: {
                // MARK: Compact Leading
                Image(systemName: "figure.walk")
                    .foregroundColor(context.state.colorState.accentColor)
                    .font(.system(size: 16))

            } compactTrailing: {
                // MARK: Compact Trailing
                Text(context.state.shortFormattedElapsedTime)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(context.state.colorState.accentColor)
                    .monospacedDigit()

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
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(context.state.colorState.accentColor)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("UnChair Active Time")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text(context.state.colorState.statusText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(context.state.colorState.accentColor)
                    .cornerRadius(8)
            }

            // Time Display
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ELAPSED TIME")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.3)

                    Text(context.state.formattedElapsedTime)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("REMAINING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.3)

                    Text(context.state.formattedTimeRemaining)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    context.state.colorState.progressColor,
                                    context.state.colorState.progressColor.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * min(context.state.progressPercentage, 1.0),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            // Progress Percentage & Button
            HStack {
                Text(context.state.formattedProgress)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                // Take Break Button
                Button(intent: TakeBreakIntent()) {
                    HStack(spacing: 5) {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Take Break")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(
                            colors: [
                                context.state.colorState.accentColor,
                                context.state.colorState.accentColor.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
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
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Break Time")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text("On Break")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
            }

            // Time Display
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TIME REMAINING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.3)

                    Text(context.state.formattedBreakTimeRemaining)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("PROGRESS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.3)

                    Text("\(Int(context.state.breakProgress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green,
                                    Color.green.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * context.state.breakProgress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            // Message
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(.green)

                Text("Enjoy your break!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }
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

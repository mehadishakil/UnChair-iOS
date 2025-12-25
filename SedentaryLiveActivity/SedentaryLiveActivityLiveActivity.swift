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
                        Text("Active Time")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(context.state.formattedElapsedTime)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(context.state.colorState.progressColor)
                                    .frame(
                                        width: geometry.size.width * min(context.state.progressPercentage, 1.0),
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)

                        // Time Remaining / Over Limit
                        HStack {
                            Text(context.state.formattedTimeRemaining)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            // Take Break Button
                            Button(intent: TakeBreakIntent()) {
                                HStack(spacing: 4) {
                                    Image(systemName: "figure.stand")
                                    Text("Break")
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(context.state.colorState.accentColor)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
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
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(context.state.colorState.accentColor)
                    .font(.title3)

                Text("UnChair Active Time")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(context.state.colorState.statusText)
                    .font(.caption)
                    .foregroundColor(context.state.colorState.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(context.state.colorState.accentColor.opacity(0.2))
                    .cornerRadius(8)
            }

            // Time Display
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(context.state.formattedElapsedTime)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(context.state.colorState.accentColor)
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(context.state.formattedTimeRemaining)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    context.state.colorState.progressColor,
                                    context.state.colorState.progressColor.opacity(0.7)
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
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Take Break Button
                Button(intent: TakeBreakIntent()) {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.stand")
                        Text("Take Break")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(context.state.colorState.accentColor)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(context.state.colorState.backgroundColor)
        .activityBackgroundTint(context.state.colorState.backgroundColor)
        .activitySystemActionForegroundColor(context.state.colorState.accentColor)
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

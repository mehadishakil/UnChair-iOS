//
//  SedentaryLiveActivity.swift
//  SedentaryLiveActivity
//
//  Home screen widget for sedentary time tracking
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            isOnBreak: false,
            timeElapsed: 0,
            breakTimeRemaining: 0,
            breakIntervalMins: 60,
            breakDurationMins: 0
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let storage = AppGroupStorage.shared
        return createEntry(date: Date(), configuration: configuration, storage: storage)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let storage = AppGroupStorage.shared
        let currentDate = Date()

        // Generate timeline entries every 1 minute for the next hour
        // This allows the widget to update frequently and show color changes
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(date: entryDate, configuration: configuration, storage: storage)
            entries.append(entry)
        }

        // Refresh timeline after 1 hour
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func createEntry(date: Date, configuration: ConfigurationAppIntent, storage: AppGroupStorage) -> SimpleEntry {
        var isOnBreak = storage.isOnBreak
        let breakIntervalMins = storage.breakIntervalMins
        var sessionStartForWidget: Date? = nil

        // Check if break has actually ended (important for when app is closed)
        if isOnBreak && storage.breakEndTime > 0 {
            let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
            if date >= breakEnd {
                // Break has ended, switch to active mode
                isOnBreak = false
                // Set session start to break end time so we count from 0
                sessionStartForWidget = breakEnd
                print("📱 Widget detected break ended at \(date), counting from \(breakEnd)")
            }
        }

        // Calculate time elapsed or break remaining
        let timeElapsed: Int
        let breakTimeRemaining: Int

        if isOnBreak && storage.breakEndTime > 0 {
            let breakEnd = Date(timeIntervalSince1970: storage.breakEndTime)
            breakTimeRemaining = max(0, Int(breakEnd.timeIntervalSince(date)))
        } else {
            breakTimeRemaining = 0
        }

        if !isOnBreak {
            // Use widget session start if break just ended, otherwise use stored lastBreakTime
            let sessionStart: Date
            if let widgetStart = sessionStartForWidget {
                sessionStart = widgetStart
            } else {
                let lastBreakTime = storage.lastBreakTime
                sessionStart = lastBreakTime > 0 ? Date(timeIntervalSince1970: lastBreakTime) : getActiveHourStart(storage: storage)
            }
            timeElapsed = max(0, Int(date.timeIntervalSince(sessionStart)))
        } else {
            timeElapsed = 0
        }

        return SimpleEntry(
            date: date,
            configuration: configuration,
            isOnBreak: isOnBreak,
            timeElapsed: timeElapsed,
            breakTimeRemaining: breakTimeRemaining,
            breakIntervalMins: breakIntervalMins,
            breakDurationMins: storage.breakDurationMinutes
        )
    }

    private func getActiveHourStart(storage: AppGroupStorage) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = storage.workStartHour
        components.minute = storage.workStartMinute

        return calendar.date(from: components) ?? now
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let isOnBreak: Bool
    let timeElapsed: Int
    let breakTimeRemaining: Int
    let breakIntervalMins: Int
    let breakDurationMins: Int

    // Simple color scheme: Orange for break time, Green for active time
    var color: Color {
        if isOnBreak {
            return .orange
        } else {
            return .green
        }
    }

    var formattedTime: String {
        let seconds = isOnBreak ? breakTimeRemaining : timeElapsed
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    var statusText: String {
        if isOnBreak {
            return "On Break"
        } else {
            return "Active"
        }
    }
}

struct SedentaryLiveActivityEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        SmallWidgetView(entry: entry)
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            // Icon and title
            HStack(spacing: 6) {
                Image(systemName: entry.isOnBreak ? "cup.and.saucer.fill" : "figure.walk")
                    .foregroundColor(entry.color)
                    .font(.title3)

                Text(entry.isOnBreak ? "Break" : "Active")
                    .font(.caption)
                    .foregroundColor(.primary)

                Spacer()
            }

            Spacer()

            // Timer
            Text(entry.formattedTime)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(entry.color)
                .monospacedDigit()

            // Status
            Text(entry.statusText)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .containerBackground(entry.color.opacity(0.1), for: .widget)
    }
}

struct SedentaryLiveActivity: Widget {
    let kind: String = "SedentaryLiveActivity"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SedentaryLiveActivityEntryView(entry: entry)
        }
        .configurationDisplayName("UnChair Timer")
        .description("Track your active time and break time")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview("Small - Work Mode Green", as: .systemSmall) {
    SedentaryLiveActivity()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        isOnBreak: false,
        timeElapsed: 1200,
        breakTimeRemaining: 0,
        breakIntervalMins: 60,
        breakDurationMins: 0
    )
}

#Preview("Small - Work Mode Orange", as: .systemSmall) {
    SedentaryLiveActivity()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        isOnBreak: false,
        timeElapsed: 3000,
        breakTimeRemaining: 0,
        breakIntervalMins: 60,
        breakDurationMins: 0
    )
}

#Preview("Small - Break Mode", as: .systemSmall) {
    SedentaryLiveActivity()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        isOnBreak: true,
        timeElapsed: 0,
        breakTimeRemaining: 300,
        breakIntervalMins: 60,
        breakDurationMins: 10
    )
}

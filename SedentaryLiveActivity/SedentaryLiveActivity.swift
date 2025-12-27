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
            breakDurationMins: 0,
            isWithinWorkHours: true
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

        // Generate timeline entries every 1 minute for the next 15 minutes
        // More frequent updates to catch work hour changes quickly
        for minuteOffset in 0 ..< 15 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(date: entryDate, configuration: configuration, storage: storage)
            entries.append(entry)
        }

        // Refresh timeline after 15 minutes (more frequent than 1 hour)
        // This ensures widget updates within 15 minutes of work hour changes
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func createEntry(date: Date, configuration: ConfigurationAppIntent, storage: AppGroupStorage) -> SimpleEntry {
        // Check if we're within work hours
        let isWithinWorkHours = checkIsWithinWorkHours(date: date, storage: storage)

        var isOnBreak = storage.isOnBreak
        let breakIntervalMins = storage.breakIntervalMins
        var sessionStartForWidget: Date? = nil

        // If outside work hours, force everything to inactive state
        if !isWithinWorkHours {
            return SimpleEntry(
                date: date,
                configuration: configuration,
                isOnBreak: false,
                timeElapsed: 0,
                breakTimeRemaining: 0,
                breakIntervalMins: breakIntervalMins,
                breakDurationMins: 0,
                isWithinWorkHours: false
            )
        }

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
            breakDurationMins: storage.breakDurationMinutes,
            isWithinWorkHours: true
        )
    }

    private func checkIsWithinWorkHours(date: Date, storage: AppGroupStorage) -> Bool {
        let calendar = Calendar.current
        let nowComps = calendar.dateComponents([.hour, .minute, .second], from: date)
        let currentSecs = (nowComps.hour! * 3600) + (nowComps.minute! * 60) + nowComps.second!

        let startSecs = (storage.workStartHour * 3600) + (storage.workStartMinute * 60)
        let endSecs = (storage.workEndHour * 3600) + (storage.workEndMinute * 60)

        let isWithin: Bool
        if startSecs <= endSecs {
            // No midnight wrap
            isWithin = currentSecs >= startSecs && currentSecs <= endSecs
        } else {
            // Wraps past midnight
            isWithin = currentSecs >= startSecs || currentSecs <= endSecs
        }

        print("📱 Widget work hours check: date=\(date), workHours=\(storage.workStartHour):\(storage.workStartMinute)-\(storage.workEndHour):\(storage.workEndMinute), isWithin=\(isWithin)")
        return isWithin
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
    let isWithinWorkHours: Bool

    // Simple color scheme: Orange for break time, Green for active time, Gray for outside hours
    var color: Color {
        if !isWithinWorkHours {
            return .gray
        } else if isOnBreak {
            return .orange
        } else {
            return .green
        }
    }

    var formattedTime: String {
        if !isWithinWorkHours {
            return "00:00"
        }
        let seconds = isOnBreak ? breakTimeRemaining : timeElapsed
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    var statusText: String {
        if !isWithinWorkHours {
            return "Outside Hours"
        } else if isOnBreak {
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
        if entry.isWithinWorkHours {
            // Normal active/break mode
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
        } else {
            // Outside work hours - different design
            VStack(spacing: 8) {
                // Moon icon indicating closed/inactive
                HStack(spacing: 6) {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.gray)
                        .font(.title3)

                    Text("Closed")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }

                Spacer()

                // Show 00:00
                Text("00:00")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .monospacedDigit()

                // Status
                Text("Outside Hours")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .containerBackground(Color.gray.opacity(0.1), for: .widget)
        }
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
        breakDurationMins: 0,
        isWithinWorkHours: true
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
        breakDurationMins: 0,
        isWithinWorkHours: true
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
        breakDurationMins: 10,
        isWithinWorkHours: true
    )
}

#Preview("Small - Outside Hours", as: .systemSmall) {
    SedentaryLiveActivity()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        isOnBreak: false,
        timeElapsed: 0,
        breakTimeRemaining: 0,
        breakIntervalMins: 60,
        breakDurationMins: 0,
        isWithinWorkHours: false
    )
}

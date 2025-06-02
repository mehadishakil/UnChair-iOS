//
//  BreakTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/8/24.
//

import SwiftUI

struct BreakTime: View {
    // Use AppStorage instead of SettingsManager for consistency with onboarding
    @AppStorage("breakIntervalMins") private var breakIntervalMins: Int = 60 // 1 hour default
    
    @State private var tempDuration: TimeDuration = TimeDuration(hours: 1, minutes: 0)
    @State private var isPickerPresented = false

    // Computed property to create TimeDuration from AppStorage value
    private var breakDuration: TimeDuration {
        TimeDuration(fromTotalMinutes: breakIntervalMins)
    }

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .frame(width: 20, alignment: .center)

            Text("Focus Time")

            Spacer()

            Button {
                tempDuration = breakDuration
                isPickerPresented = true
            } label: {
                Text("\(breakDuration.hours) hr \(breakDuration.minutes) min")
                    .padding(6)
                    .font(.subheadline.weight(.semibold))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .sheet(isPresented: $isPickerPresented) {
                BreakDurationPicker(
                    duration: $tempDuration
                ) {
                    // Update AppStorage value from selected duration
                    breakIntervalMins = tempDuration.totalMinutes
                    
                    // Optionally sync with SettingsManager if still needed elsewhere
                    syncWithSettingsManager()
                    
                    // Post notification for other parts of the app that might depend on it
                    NotificationCenter.default.post(name: .breakSettingsChanged, object: nil)
                }
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    // Optional: Sync with SettingsManager if other parts of your app still depend on it
    private func syncWithSettingsManager() {
        SettingsManager.shared.breakDuration = TimeDuration(fromTotalMinutes: breakIntervalMins)
    }
}

struct BreakDurationPicker: View {
    @Binding var duration: TimeDuration
    @Environment(\.presentationMode) private var presentationMode
    let onSave: () -> Void

    // picker ranges
    private let hours = Array(0...12)
    private let minutes = Array(0...59)

    var body: some View {
        VStack(spacing: 24) {
            // custom handle
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)

            Text("Focus Time")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // wheel pickers
            HStack(spacing: 32) {
                wheelPicker(selection: $duration.hours, data: hours, label: "hr")
                wheelPicker(selection: $duration.minutes, data: minutes, label: "min")
            }

            // live preview
            Text("\(duration.hours) hr \(duration.minutes) min")
                .font(.headline.weight(.bold))
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer()

            // save button
            Button {
                onSave()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding()
    }

    @ViewBuilder
    private func wheelPicker(selection: Binding<Int>, data: [Int], label: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("", selection: selection) {
                ForEach(data, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 100)
            .clipped()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    BreakTime()
}

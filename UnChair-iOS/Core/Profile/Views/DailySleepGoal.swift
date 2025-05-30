//
//  DailySleepGoal.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/5/25.
//

import SwiftUI

struct DailySleepGoal: View {
    @AppStorage("sleepGoalMins") private var sleepGoalMins: Int = 8 * 60
    @State private var tempDuration: TimeDuration
    @State private var isPickerPresented = false

    init() {
        let saved = UserDefaults.standard.integer(forKey: "sleepGoalMins")
        _tempDuration = State(initialValue: TimeDuration(fromTotalMinutes: saved))
    }

    var body: some View {
        HStack {
            Image(systemName: "powersleep")
                .frame(width: 20, alignment: .center)
            Text("Sleep Goal")
            Spacer()

            Button {
                tempDuration = TimeDuration(fromTotalMinutes: sleepGoalMins)
                isPickerPresented = true
            } label: {
                Text("\(sleepGoalMins / 60) hr \(sleepGoalMins % 60) min")
                    .padding(6)
                    .font(.subheadline.weight(.semibold))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .sheet(isPresented: $isPickerPresented) {
                DailySleepGoalPickerView(duration: $tempDuration) {
                    sleepGoalMins = tempDuration.totalMinutes
                    NotificationCenter.default.post(name: .breakSettingsChanged, object: nil)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}

struct DailySleepGoalPickerView: View {
    @Binding var duration: TimeDuration
    @Environment(\.presentationMode) private var presentationMode
    let onSave: () -> Void

    private let hours = Array(4...14)
    private let minutes = Array(0...59)

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .frame(width: 80, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)

            Text("Set Daily Sleep Goal")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 32) {
                wheelPicker(selection: $duration.hours, data: hours, label: "hr")
                wheelPicker(selection: $duration.minutes, data: minutes, label: "min")
            }

            Text("\(duration.hours) hr \(duration.minutes) min")
                .font(.headline.weight(.bold))
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer()

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
                .font(.footnote)
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
    DailySleepGoal()
}

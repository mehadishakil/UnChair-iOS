//
//  ActiveHour.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/7/24.
//

import SwiftUI

struct ActiveHour: View {
    @StateObject private var settings = SettingsManager.shared
    @State private var tempStartTime: Date
    @State private var tempEndTime: Date
    @State private var isStartTimePickerPresented = false
    
    init() {
        _tempStartTime = State(initialValue: SettingsManager.shared.startTime)
        _tempEndTime = State(initialValue: SettingsManager.shared.endTime)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.2.circlepath")
            
            Text("Work Hour")
            
            Spacer()
            
            Button(action: {
                tempStartTime = settings.startTime
                tempEndTime = settings.endTime
                isStartTimePickerPresented = true
            }) {
                HStack{
                    Text("\(formattedTime(settings.startTime))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("to")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(formattedTime(settings.endTime))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            }
            .sheet(isPresented: $isStartTimePickerPresented) {
                TimePickerView(startTime: $tempStartTime, endTime: $tempEndTime, onSave: {
                    settings.startTime = tempStartTime
                    settings.endTime = tempEndTime
                })
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct TimePickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var startTime: Date
    @Binding var endTime: Date
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var selectingStart = true

    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Text("Set Time Range")
                .font(.title2.weight(.bold))

            // Start / End pickers
            HStack(spacing: 16) {
                timeField(
                    icon: "clock",
                    label: "Start",
                    time: startTime,
                    isActive: selectingStart
                )
                .onTapGesture { selectingStart = true }

                timeField(
                    icon: "clock.fill",
                    label: "End",
                    time: endTime,
                    isActive: !selectingStart
                )
                .onTapGesture { selectingStart = false }
            }

            // Duration display
            HStack {
                Text("Duration")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(durationHours) h \(durationMinutes) m")
                    .font(.body.weight(.bold))
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Time wheel
            DatePicker(
                "",
                selection: selectingStart ? $startTime : $endTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .background(.ultraThinMaterial)
            .frame(height: 150)        // <- whatever height you like
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onChange(of: startTime) { _ in updateDuration() }
            .onChange(of: endTime)   { _ in updateDuration() }

            

            // Save button
            Button {
                onSave()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding()
        .onAppear { updateDuration() }
    }

    @ViewBuilder
    private func timeField(icon: String, label: String, time: Date, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(formattedTime(time))
                .font(.headline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isActive ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func updateDuration() {
        let cal = Calendar.current
        let actualEnd = endTime < startTime
            ? cal.date(byAdding: .day, value: 1, to: endTime)!
            : endTime

        let comps = cal.dateComponents([.hour, .minute], from: startTime, to: actualEnd)
        durationHours   = comps.hour ?? 0
        durationMinutes = comps.minute ?? 0
    }
}


#Preview {
    ActiveHour()
}

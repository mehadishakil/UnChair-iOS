//
//  ActiveHour.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/7/24.
//

import SwiftUI
import WidgetKit

struct ActiveHour: View {
    @AppStorage("workStartHour") private var workStartHour: Int = 9
    @AppStorage("workStartMinute") private var workStartMinute: Int = 0
    @AppStorage("workEndHour") private var workEndHour: Int = 17
    @AppStorage("workEndMinute") private var workEndMinute: Int = 0
    
    @State private var tempStartTime: Date = Date()
    @State private var tempEndTime: Date = Date()
    @State private var isStartTimePickerPresented = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass // for ipad wide screen

    
    // Computed properties to create Date objects from AppStorage values
    private var startTime: Date {
        var components = DateComponents()
        components.hour = workStartHour
        components.minute = workStartMinute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private var endTime: Date {
        var components = DateComponents()
        components.hour = workEndHour
        components.minute = workEndMinute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.2.circlepath")
                .frame(width: 20, alignment: .center)
            
            Text("Work Hour")
            
            Spacer()
            
            Button(action: {
                tempStartTime = startTime
                tempEndTime = endTime
                isStartTimePickerPresented = true
            }) {
                HStack{
                    Text("\(formattedTime(startTime))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("to")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(formattedTime(endTime))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            }
            .sheet(isPresented: $isStartTimePickerPresented) {
                TimePickerView(
                    startTime: $tempStartTime,
                    endTime: $tempEndTime,
                    onSave: {
                        // Update AppStorage values from selected times
                        let calendar = Calendar.current
                        workStartHour = calendar.component(.hour, from: tempStartTime)
                        workStartMinute = calendar.component(.minute, from: tempStartTime)
                        workEndHour = calendar.component(.hour, from: tempEndTime)
                        workEndMinute = calendar.component(.minute, from: tempEndTime)

                        // Sync with AppGroupStorage for widgets and Live Activity
                        let storage = AppGroupStorage.shared
                        storage.workStartHour = workStartHour
                        storage.workStartMinute = workStartMinute
                        storage.workEndHour = workEndHour
                        storage.workEndMinute = workEndMinute

                        // CRITICAL: Reload widgets immediately when work hours change
                        WidgetCenter.shared.reloadAllTimelines()
                        print("✅ Work hours changed - reloaded all widgets")

                        // Update Live Activity if it's running
                        if #available(iOS 16.1, *) {
                            LiveActivityManager.shared.refreshOnAppBecameActive()
                        }

                        // Optionally sync with SettingsManager if still needed elsewhere
                        syncWithSettingsManager()
                    }
                )
                .presentationDetents([horizontalSizeClass == .compact ? .fraction(0.7) : .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Optional: Sync with SettingsManager if other parts of your app still depend on it
    private func syncWithSettingsManager() {
        var startComponents = DateComponents()
        startComponents.hour = workStartHour
        startComponents.minute = workStartMinute
        if let startTime = Calendar.current.date(from: startComponents) {
            SettingsManager.shared.startTime = startTime
        }
        
        var endComponents = DateComponents()
        endComponents.hour = workEndHour
        endComponents.minute = workEndMinute
        if let endTime = Calendar.current.date(from: endComponents) {
            SettingsManager.shared.endTime = endTime
        }
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
                .padding(.top)

            Spacer()
            
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
                    .font(.headline.weight(.bold))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            Spacer()

            // Time wheel
            DatePicker(
                "",
                selection: selectingStart ? $startTime : $endTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .background(.ultraThinMaterial)
            .frame(height: 150)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onChange(of: startTime) { _ in updateDuration() }
            .onChange(of: endTime)   { _ in updateDuration() }

            Spacer()
            
            // Save button
            Button {
                onSave()
                UserDefaults.standard.removeObject(forKey: "LastBreakTime")
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

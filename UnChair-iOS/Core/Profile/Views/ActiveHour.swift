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
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            }
            .sheet(isPresented: $isStartTimePickerPresented) {
                TimePickerView(startTime: $tempStartTime, endTime: $tempEndTime, onSave: {
                    settings.startTime = tempStartTime
                    settings.endTime = tempEndTime
                })
                .presentationDetents([.fraction(0.7), .large])
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
    @Environment(\.presentationMode) var presentationMode
    @Binding var startTime: Date
    @Binding var endTime: Date
    var onSave: () -> Void
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    @State private var isSelectingStartTime: Bool = true
    
    init(startTime: Binding<Date>, endTime: Binding<Date>, onSave: @escaping () -> Void) {
        self._startTime = startTime
        self._endTime = endTime
        self.onSave = onSave
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startTime.wrappedValue, to: endTime.wrappedValue)
        self._durationHours = State(initialValue: components.hour ?? 0)
        self._durationMinutes = State(initialValue: components.minute ?? 0)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("How long?")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.top, 12)
                
                HStack {
                    Image(systemName: "clock")
                    
                    Text("Duration")
                        .font(.subheadline)
                    Spacer()
                    Text("\(durationHours) h \(durationMinutes) m")
                        .font(.subheadline)
                        .padding(6)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.purple, lineWidth: 1)
                        )
                }
                .padding(.bottom, 24)
                
                Text("When?")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.bottom, 6)
                
                HStack {
                    Image(systemName: "clock")
                    
                    Text("At time")
                        .font(.subheadline)
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button(action: {
                        isSelectingStartTime = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text("Start:")
                                .font(.callout)
                            Text("\(formattedTime(startTime))")
                        }
                        .padding(6)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelectingStartTime ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        isSelectingStartTime = false
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text("End:")
                                .font(.callout)
                            Text("\(formattedTime(endTime))")
                        }
                        .padding(6)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelectingStartTime ? Color.gray.opacity(0.3) : Color.purple, lineWidth: 2)
                        )
                    }
                }
                
                DatePicker("", selection: isSelectingStartTime ? $startTime : $endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .onChange(of: startTime) { _, _ in
                        updateDuration()
                    }
                    .onChange(of: endTime) { _, _ in
                        updateDuration()
                    }
            }
            .padding()
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateDuration() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: startTime, to: endTime)
        durationHours = components.hour ?? 0
        durationMinutes = components.minute ?? 0
        
        // Ensure end time is always after start time
        if endTime < startTime {
            endTime = startTime.addingTimeInterval(3600) // Set to 1 hour later if end time is before start time
        }
    }
}

#Preview {
    ActiveHour()
}

//
//  BreakTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/8/24.
//

import SwiftUI

struct BreakTime: View {
    @StateObject private var settings = SettingsManager.shared
    @State private var isTimePickerPresented = false
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
            
            Text("Break Time")
            
            Spacer()
            
            Button(action: {
                isTimePickerPresented = true
            }) {
                Text("\(settings.breakDuration.hours) hr \(settings.breakDuration.minutes) min")
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .sheet(isPresented: $isTimePickerPresented) {
                CustomTimePicker(selectedDuration: $settings.breakDuration, onDismiss: {
                    // Notify that break settings changed
                    NotificationCenter.default.post(name: .breakSettingsChanged, object: nil)
                })
                .presentationDetents([.fraction(0.5), .medium])
            }
        }
    }
}


struct CustomTimePicker: View {
    @Binding var selectedDuration: TimeDuration
    @Environment(\.presentationMode) var presentationMode
    let onDismiss: () -> Void
    
    let hourRange = 0...12
    let minuteRange = 0...59
    
    var body: some View {
        VStack {
            Text("How often do you want to take break?")
                .font(.headline)
                .padding()
                .padding(.top, 20)
            
            HStack {
                Picker("Hours", selection: $selectedDuration.hours) {
                    ForEach(hourRange, id: \.self) { hour in
                        Text("\(hour) hr").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                
                Picker("Minutes", selection: $selectedDuration.minutes) {
                    ForEach(minuteRange, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
            }
            
            Text("\(selectedDuration.hours) hr \(selectedDuration.minutes) min")
                .padding()
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
                onDismiss()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

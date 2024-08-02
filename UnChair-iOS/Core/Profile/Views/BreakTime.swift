//
//  BreakTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 2/8/24.
//

import SwiftUI

struct BreakTime: View {
    @Binding var selectedDuration: TimeDuration
    @State private var isTimePickerPresented = false
    
    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.2.circlepath")
            
            Text("Break Time")
            
            Spacer()
            
            Button(action: {
                isTimePickerPresented = true
            }) {
                Text("\(selectedDuration.hours) hr \(selectedDuration.minutes) min")
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            .sheet(isPresented: $isTimePickerPresented) {
                CustomTimePicker(selectedDuration: $selectedDuration)
            }
        }
    }
}


struct CustomTimePicker: View {
    @Binding var selectedDuration: TimeDuration
    @Environment(\.presentationMode) var presentationMode
    
    let hourRange = 0...12
    let minuteRange = 0...59
    
    var body: some View {
        VStack {
            Text("How often do you want to take break?")
                .font(.headline)
                .padding()
            
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
            }
            .padding()
        }
    }
}


#Preview {
    ContentView()
}

//
//  ActiveHour.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/7/24.
//

import SwiftUI

struct ActiveHour: View {
    
    @State private var startTime = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!
    @State private var endTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var isStartTimePickerPresented = false
    @State private var isEndTimePickerPresented = false
    
    var body: some View {
        HStack {
            Image(systemName: "person.badge.clock")
            
            Text("Work Hour")

            
            Spacer()
            
            Button(action: {
                isStartTimePickerPresented = true
            }) {
                Text("\(formattedTime(startTime))")
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            .sheet(isPresented: $isStartTimePickerPresented) {
                TimePickerView(selectedTime: $startTime, title: "Select Start Time")
            }
            
            Text("to")
            
            Button(action: {
                isEndTimePickerPresented = true
            }) {
                Text("\(formattedTime(endTime))")
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            .sheet(isPresented: $isEndTimePickerPresented) {
                TimePickerView(selectedTime: $endTime, title: "Select End Time")
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
    @Binding var selectedTime: Date
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}


#Preview {
    ActiveHour()
}

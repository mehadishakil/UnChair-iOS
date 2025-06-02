//
//  SleepSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//

import SwiftUI

struct SleepSelectionView: View {
    @Binding var selectedSleep: TimeDuration
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    private let hours = Array(4...14)
    private let minutes = Array(0...59)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("Set your daily ")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Text("sleep ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("target?")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Text("Set how much do you want to\nsleep each day.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }

                    VStack {
                        HStack(spacing: 24) {
                            wheelPicker(selection: $selectedSleep.hours, data: hours, label: "Hours")
                            wheelPicker(selection: $selectedSleep.minutes, data: minutes, label: "Minutes")
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func wheelPicker(selection: Binding<Int>, data: [Int], label: String) -> some View {
        VStack {
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)

            Picker("", selection: selection) {
                ForEach(data, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .background(.ultraThinMaterial)
            .pickerStyle(.wheel)
            .frame(width: 140)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    SleepSelectionView(selectedSleep: .constant(TimeDuration.init(hours: 6, minutes: 30)))
}

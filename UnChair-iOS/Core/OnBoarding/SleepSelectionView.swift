//
//  SleepSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/5/25.
//

import SwiftUI

struct SleepSelectionView: View {
    @State private var selectedSteps: Int = 10000
    @State private var showNextScreen: Bool = false
    @State private var value: CGFloat = 10
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing : 8) {
                        HStack(spacing: 0) {
                            Text("Set our daily ")
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

                        SleepPicker()

                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    struct SleepPicker: View {
        @State private var tempDuration: TimeDuration
        private let hours = Array(4...14)
        private let minutes = Array(0...59)

        init() {
            let saved = UserDefaults.standard.integer(forKey: "sleepGoalMins")
            _tempDuration = State(initialValue: TimeDuration(fromTotalMinutes: saved))
        }

        var body: some View {
            VStack {
                HStack(spacing: 24) {
                    wheelPicker(selection: $tempDuration.hours, data: hours, label: "Hours")
                    wheelPicker(selection: $tempDuration.minutes, data: minutes, label: "Minutes")
                }
            }
            .padding()
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
                .frame(width: 100)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
    
}




#Preview {
    SleepSelectionView()
}

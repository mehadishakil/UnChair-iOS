//
//  BreakIntervalSelectionView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/6/25.
//

import SwiftUI

struct BreakIntervalSelectionView: View {
    @Binding var selectedBreakInterval: TimeDuration
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    private let hours = Array(0...4)  // More reasonable range for break intervals
    private let minutes = Array(stride(from: 0, through: 55, by: 5)) // 5-minute increments
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("Set your ")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Text("break ")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            Text("interval")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Text("Set your preferred focus duration\nbefore taking a break.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    }
                    
                    VStack {
                        HStack(spacing: 24) {
                            wheelPicker(selection: $selectedBreakInterval.hours, data: hours, label: "Hours")
                            wheelPicker(selection: $selectedBreakInterval.minutes, data: minutes, label: "Minutes")
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
    BreakIntervalSelectionView(selectedBreakInterval: .constant(TimeDuration.init(hours: 1, minutes: 30)))
}

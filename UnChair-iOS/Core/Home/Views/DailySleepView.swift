//
//  DailySleepView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailySleepView: View {
    @State private var showSleepPicker = false
    @EnvironmentObject private var healthViewModel: HealthDataViewModel

    var body: some View {
        CardView {
            VStack(spacing: 16) {
                Image(systemName: "bed.double")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: 4) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(String(format: "%.1f", healthViewModel.sleepHours))
                            .font(.system(size: 24, weight: .bold))

                        Text("h")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 2)
                    }
                    Text("Sleep")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .onTapGesture {
                showSleepPicker.toggle()
            }
            .sheet(isPresented: $showSleepPicker) {
                SleepPickerView(sleep: healthViewModel.sleepHours, onUpdate: { newValue in
                    healthViewModel.updateSleepHours(newValue)
                })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .shadow(radius: 1)
    }
}

struct SleepPickerView: View {
    @State private var selectedSleepIndex: Int
    let onUpdate: (Float) -> Void
    @Environment(\.dismiss) private var presentationMode
    private let sleepValues = Array(stride(from: 0.0, through: 12.0, by: 0.1))

    init(sleep: Float, onUpdate: @escaping (Float) -> Void) {
        self.onUpdate = onUpdate
        let initialIndex = Int((sleep * 10).rounded())
        self._selectedSleepIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        VStack {
            Text("Today's Sleeping Duration (hours)")
                .font(.headline)
                .padding()

            Picker("Sleep Hours", selection: $selectedSleepIndex) {
                ForEach(0..<sleepValues.count, id: \.self) { index in
                    Text(String(format: "%.1f", sleepValues[index])).tag(index)
                }
            }
            .labelsHidden()
            .padding()

            Button(action: {
                let newSleepValue = Float(sleepValues[selectedSleepIndex])
                onUpdate(newSleepValue)
                presentationMode.callAsFunction()
            }) {
                Text("Done")
                    .bold()
            }
            .padding()
        }
        .padding()
    }
}

struct CardView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    DailySleepView()
}

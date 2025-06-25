//
//  DailyStepsGoal.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/5/25.
//


import SwiftUI

struct DailyStepsGoal: View {
    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
    @State private var steps: Int = UserDefaults.standard.integer(forKey: "stepsGoal")
    @State private var isPickerPresented = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass // for ipad wide screen


    var body: some View {
        HStack {
            Image(systemName: "figure.walk")
                .frame(width: 20, alignment: .center)
            Text("Steps Goal")
            Spacer()
            
            Button {
                // load current goal into buffer and show picker
                steps = stepsGoal
                isPickerPresented = true
            } label: {
                Text("\(stepsGoal) steps")
                    .padding(6)
                    .font(.subheadline.weight(.semibold))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .sheet(isPresented: $isPickerPresented) {
                StepsGoalPickerView(
                    steps: $steps
                ) {
                    // save buffer back to AppStorage
                    stepsGoal = steps
                    NotificationCenter.default.post(name: .breakSettingsChanged, object: nil)
                }
                .presentationDetents([horizontalSizeClass == .compact ? .medium : .large])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}

struct StepsGoalPickerView: View {
    @Binding var steps: Int
    @Environment(\.presentationMode) private var presentationMode
    let onSave: () -> Void

    private let stepsRange: [Int] = Array(stride(from: 1000, through: 20000, by: 100))

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)

            Text("Set Daily Steps Goal")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            wheelPicker(selection: $steps, data: stepsRange, label: "steps")

            Spacer()

            Button {
                onSave()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding()
    }

    @ViewBuilder
    private func wheelPicker(selection: Binding<Int>, data: [Int], label: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)

            Picker("", selection: selection) {
                ForEach(data, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 250, height: 200)
            .clipped()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    DailyStepsGoal()
}

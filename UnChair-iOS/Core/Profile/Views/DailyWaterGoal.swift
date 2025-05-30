//
//  WaterDailyGoal.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 30/5/25.
//

import SwiftUI

struct DailyWaterGoal: View {
    @AppStorage("waterGoalML") private var waterGoalML: Int = 2000
    @State private var water: Int = UserDefaults.standard.integer(forKey: "waterGoalML")
    @State private var isPickerPresented = false

    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .frame(width: 20, alignment: .center)
            Text("Water Goal")
            Spacer()
            
            Button {
                water = waterGoalML
                isPickerPresented = true
            } label: {
                Text("\(waterGoalML) ml")
                    .padding(6)
                    .font(.subheadline.weight(.semibold))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .sheet(isPresented: $isPickerPresented) {
                WaterGoalPickerView(
                    water: $water
                ) {
                    // save buffer back to AppStorage
                    waterGoalML = water
                    NotificationCenter.default.post(name: .breakSettingsChanged, object: nil)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}


struct WaterGoalPickerView: View {
    @Binding var water: Int
    @Environment(\.presentationMode) private var presentationMode
    let onSave: () -> Void

    // e.g. from 0 to 5000 ml in 100-ml steps
    private let waterRange: [Int] = Array(stride(from: 1000, through: 8000, by: 100))

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .frame(width: 80, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)

            Text("Set Daily Water Goal")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            wheelPicker(selection: $water, data: waterRange, label: "milliliter")

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
            .frame(width: 300, height: 200)
            .clipped()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    DailyWaterGoal()
}

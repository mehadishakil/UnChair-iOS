//
//  DailySleepView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailySleepView: View {
  @EnvironmentObject private var healthVM: HealthDataViewModel
  @State private var showPicker = false

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(
          LinearGradient(
            colors: [
              Color.blue.opacity(0.5),
              Color.purple.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)

      Button {
        showPicker.toggle()
      } label: {
        VStack(spacing: 12) {
          Image(systemName: "bed.double.fill")
            .font(.system(size: 30))
            .foregroundStyle(Color.white.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .center)

          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.1f", healthVM.sleepHours))
              .font(.system(.title, weight: .bold))
              .foregroundColor(.white)
            Text("h")
              .font(.system(.title2, weight: .bold))
              .foregroundColor(.white)
              .baselineOffset(-2)
          }

          Text("Sleep")
            .font(.system(.subheadline, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .frame(height: 170)
    .frame(maxWidth: .infinity)
    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    .sheet(isPresented: $showPicker) {
      SleepPickerView(sleep: healthVM.sleepHours) { newVal in
        healthVM.updateSleepHours(newVal)
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
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

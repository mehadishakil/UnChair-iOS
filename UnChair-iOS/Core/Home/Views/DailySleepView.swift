//
//  DailySleepView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//
import SwiftUI

import SwiftUI

struct DailySleepView: View {
    @State private var showSleepPicker = false
    @State public var sleep: Float = 6.5

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
                        Text(String(format: "%.1f", sleep))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Text("h")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 2)
                    }
                    Text("Sleep")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.white)
            .cornerRadius(12)
            .onTapGesture {
                showSleepPicker.toggle()
            }
            .sheet(isPresented: $showSleepPicker) {
                SleepPickerView(sleep: $sleep)
            }
        }
    }
}

struct SleepPickerView: View {
    @Binding var sleep: Float
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSleepIndex: Int
    private let sleepValues = Array(stride(from: 0.0, through: 12.0, by: 0.1))

    init(sleep: Binding<Float>) {
        self._sleep = sleep
        let initialIndex = Int((sleep.wrappedValue * 10).rounded())
        self._selectedSleepIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        VStack {
            Text("Select Sleep Hours")
                .font(.headline)
                .padding()

            Picker("Sleep Hours", selection: $selectedSleepIndex) {
                ForEach(0..<sleepValues.count, id: \.self) { index in
                    Text(String(format: "%.1f", sleepValues[index])).tag(index)
                }
            }
            .labelsHidden()
            .padding()

            Button("Done") {
                sleep = Float(sleepValues[selectedSleepIndex])
                presentationMode.wrappedValue.dismiss()
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
    DailySleepView(sleep: 6.5)
}

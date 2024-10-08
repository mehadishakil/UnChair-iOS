//
//  DailyWaterView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyWaterView: View {
    @State var waterIntake: Int = 1800
    @State private var showWaterPicker = false
    private let waterTarget: Int = 3500
    private let maxIntake: Int = 6000
    private let minIntake: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            CircularProgressBar(current: waterIntake, target: waterTarget, maxIntake: maxIntake, minIntake: minIntake)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onTapGesture {
            showWaterPicker.toggle()
        }
        .sheet(isPresented: $showWaterPicker) {
            WaterPickerView(water: $waterIntake, waterTarget: waterTarget, maxIntake: maxIntake, minIntake: minIntake)
                .presentationDetents([.fraction(0.8), .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct CircularProgressBar: View {
    var current: Int
    var target: Int
    var maxIntake: Int
    var minIntake: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
            
            if current > target {
                Circle()
                    .trim(from: 0, to: excessProgress)
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round)) // Bolder line
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
            }
            
            VStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                    .foregroundColor(.blue)
                Text("Drink Target")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                HStack {
                    Text("\(current)")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text("/ \(target)ml")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
        }
    }

    private var progress: CGFloat {
        CGFloat(min(current, maxIntake)) / CGFloat(target)
    }

    private var excessProgress: CGFloat {
        let excess = max(0, current - target)
        return CGFloat(excess) / CGFloat(target)
    }
}

struct WaterPickerView: View {
    @Binding var water: Int
    let waterTarget: Int
    let maxIntake: Int
    let minIntake: Int
    @Environment(\.dismiss) private var dismiss
    @State private var tempWater: Int

    init(water: Binding<Int>, waterTarget: Int, maxIntake: Int, minIntake: Int) {
        self._water = water
        self.waterTarget = waterTarget
        self.maxIntake = maxIntake
        self.minIntake = minIntake
        self._tempWater = State(initialValue: water.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("Adjust Water Intake")
                .font(.headline)
                .padding()
            
            CircularProgressBar(current: tempWater, target: waterTarget, maxIntake: maxIntake, minIntake: minIntake)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateProgress(with: value)
                        }
                )
            
            
            HStack(spacing: 20) {
                Button(action: { addWater(amount: 100) }) {
                    Text("+100ml")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { addWater(amount: 250) }) {
                    Text("+250ml")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: { addWater(amount: 500) }) {
                    Text("+500ml")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            Button("Done") {
                water = tempWater
                dismiss()
            }.padding()
        }
    }
    
    private func addWater(amount: Int) {
        let newAmount = tempWater + amount
        if newAmount <= maxIntake {
            tempWater = newAmount
        } else {
            tempWater = maxIntake
        }
    }

    private func updateProgress(with value: DragGesture.Value) {
        let center = CGPoint(x: 100, y: 100) // Assuming a 200x200 circle
        let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
        let angle = atan2(vector.dy, vector.dx) + .pi / 2
        let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
        let newProgress = normalizedAngle / (2 * .pi)
        let newIntake = Int(newProgress * CGFloat(maxIntake))

        if newIntake <= maxIntake && newIntake >= minIntake {
            tempWater = newIntake
        }
    }
}
#Preview {
    DailyWaterView()
}


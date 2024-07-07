//
//  DailyWaterView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyWaterView: View {
    @State private var waterIntake: Int = 1800
    private let waterTarget: Int = 2500
    private let maxIntake: Int = 3000
    private let minIntake: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            CircularProgressBar(current: $waterIntake, target: waterTarget, maxIntake: maxIntake, minIntake: minIntake)
                .frame(width: 200, height: 200)
            
            HStack {
                Button(action: {
                    if waterIntake - 200 >= minIntake {
                        waterIntake -= 200
                    }
                }) {
                    Text("-200ml")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                }
                
                Spacer()
                
                Button(action: {
                    if waterIntake + 200 <= maxIntake {
                        waterIntake += 200
                    }
                }) {
                    Text("+200ml")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                }
                
            }
            .padding(.horizontal, 30)
        }
        .padding()
    }
}

struct CircularProgressBar: View {
    @Binding var current: Int
    var target: Int
    var maxIntake: Int
    var minIntake: Int

    @State private var dragAngle: CGFloat = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 10)
                .rotationEffect(.degrees(-90))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateProgress(with: value)
                        }
                )
            
            VStack {
                Text("Drink Target")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                HStack {
                    Text("\(current)")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    Text("/\(target)ml")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
        }
    }

    private var progress: CGFloat {
        CGFloat(current) / CGFloat(target)
    }

    private func updateProgress(with value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x - 100, dy: value.location.y - 100)
        let angle = atan2(vector.dy, vector.dx) + .pi / 2
        let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
        let newProgress = normalizedAngle / (2 * .pi)
        let newIntake = Int(newProgress * CGFloat(maxIntake))

        if newIntake <= maxIntake && newIntake >= minIntake {
            current = newIntake
        }
    }
}

#Preview {
    DailyWaterView()
}

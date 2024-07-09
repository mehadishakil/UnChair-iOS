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
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
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
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateProgress(with: value)
                        }
                )
            
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

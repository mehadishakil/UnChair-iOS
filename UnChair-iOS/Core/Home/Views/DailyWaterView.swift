//
//  DailyWaterView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 7/7/24.
//

import SwiftUI

struct DailyWaterView: View {
    @EnvironmentObject private var healthViewModel: HealthDataViewModel
    @State private var showWaterPicker = false
    @AppStorage("waterGoalML") private var waterGoalML: Int = 2000
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    private let maxIntake: Int = 6000
    private let minIntake: Int = 0
    
    var body: some View {
        
        Button(action: { showWaterPicker.toggle() }) {
            ZStack{
                CircularProgressBar(current: healthViewModel.waterIntake, target: waterGoalML, maxIntake: maxIntake, minIntake: minIntake)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(
                userTheme == .system
                ? (colorScheme == .light ? .white : .darkGray)
                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
            )
            .cornerRadius(20, corners: .allCorners)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 170)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showWaterPicker) {
            WaterPickerView(currentMl: healthViewModel.waterIntake, waterGoalML: waterGoalML, maxIntake: maxIntake, minIntake: minIntake, onUpdate: { newValue in
                healthViewModel.updateWaterIntake(newValue)
            })
            .presentationDetents([.medium])
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
                .stroke(Color.white.opacity(0.7), lineWidth: 10)
                .shadow(radius: 4)
                .padding(12)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .padding(12)
            
            if current > target {
                Circle()
                    .trim(from: 0, to: excessProgress)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
                    .padding(12)
            }
            
            VStack {
                Image("water")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 36)
                Text("Water")
                    .font(.callout)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(current) ml")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
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


enum WaterUnit: String, CaseIterable, Identifiable {
    case glass, bottle
    
    var id: Self { self }
    var displayName: String {
        switch self {
        case .glass:  return "Glass"
        case .bottle: return "Bottle"
        }
    }
    /// how many ml are in one unit
    var mlPerUnit: Int {
        switch self {
        case .glass:  return 200
        case .bottle: return 300 // or whatever your bottle size is
        }
    }
}

struct WaterPickerView: View {
    @State private var selectedUnit: WaterUnit = .glass
    @State private var totalMl: Int
    let maxIntake: Int
    let onUpdate: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    private var unitCount: Int {
        totalMl / selectedUnit.mlPerUnit
    }
    
    init(currentMl: Int,
         waterGoalML: Int, maxIntake: Int, minIntake: Int,
         onUpdate: @escaping (Int) -> Void) {
        let glasses = currentMl / WaterUnit.glass.mlPerUnit
        _totalMl = State(initialValue: currentMl)
        self.maxIntake = maxIntake
        self.onUpdate = onUpdate
    }
    
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Text("Adjust Water Intake")
                    .font(.headline.bold())
                
                Picker("", selection: $selectedUnit) {
                    ForEach(WaterUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                    .padding()
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 2) Stepper for current unit
                VStack(spacing: 8) {
                    Text("How many \(selectedUnit.displayName.lowercased())\(unitCount == 1 ? "" : "s")?")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button {
                            let newTotal = totalMl - selectedUnit.mlPerUnit
                            totalMl = max(newTotal, 0)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(unitCount)")
                            .font(.system(size: 28, weight: .semibold))
                            .frame(width: 60)
                        
                        Button {
                            let newTotal = totalMl + selectedUnit.mlPerUnit
                            totalMl = min(newTotal, maxIntake)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // 3) Live conversion display
                VStack(spacing: 4) {
                    Text("Total water")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(totalMl) ml")
                        .font(.callout)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // 4) Save button
                Button(action: {
                    onUpdate(totalMl)
                    dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(totalMl > 0 ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(totalMl == 0)
            }
            .padding(.vertical)
        }
    }
}


#Preview {
    DailyWaterView()
}


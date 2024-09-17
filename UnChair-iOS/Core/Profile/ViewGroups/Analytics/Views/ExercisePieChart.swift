//
//  ExerciseLineChart.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 16/9/24.
//

//                .annotation(position: .overlay) {
//                    //                        Text(summary.count, format: .number.precision(.fractionLength(1)))
//                    //                            .font(.caption)
//                    //                            .fontWeight(.bold)
//                    //                            .foregroundColor(.white)
//                    // Text("\(summary.count)")
//                    // .foregroundColor(.white)
//                }


import SwiftUI
import SwiftData
import Charts

struct ExercisePieChart: View {
    @Binding var currentActiveItem: ExerciseChartModel?
    @Binding var plotWidth: CGFloat
    var exerciseData: ExerciseChartModel
    @Binding var currentTab: String
    @State private var selectedCount: Int?
    @State private var SelectedWineType: BreakSummary?
    @State private var animationProgress: CGFloat = 0
    var wineTypes: [BreakSummary] {
        return [
            BreakSummary(type: "Quick Break", count: exerciseData.breaks.quickBreak),
            BreakSummary(type: "Short Break", count: exerciseData.breaks.shortBreak),
            BreakSummary(type: "Medium Break", count: exerciseData.breaks.mediumBreak),
            BreakSummary(type: "Long Break", count: exerciseData.breaks.longBreak)
        ]
    }
    
    var body: some View {
        
        VStack{
            
            
            
            Chart(wineTypes) { summary in
                SectorMark(
                    angle: .value("Count", summary.count),
                    innerRadius: .ratio(0.65), // Golden ratio for aesthetics
                    outerRadius: SelectedWineType?.type == summary.type ? 175 : 150,
                    angularInset: 1
                )

                .foregroundStyle(by: .value("Break Type", summary.type))
                .cornerRadius(10)
                
            }
            .chartAngleSelection(value: $selectedCount)
            .chartBackground { _ in
                if let SelectedWineType {
                    VStack {
                        Text(SelectedWineType.type)
                            .font(.title3)
                        
                        Text("\(SelectedWineType.count)")
                            .font(.caption)
                    }
                }
            }
            .chartLegend(position: .bottom)
            .frame(height: 350)
            .padding()
        }
        .frame(height: 350)
        .onAppear {
            print("Fetched Exercise Data: \(exerciseData)")
            withAnimation(.easeInOut(duration: 1.0)) {
                            animationProgress = 1.0
                        }
        }
        .onChange(of: selectedCount) { oldValue, newValue in
            if let newValue {
                withAnimation{
                    getSelectedWineType(value: newValue)
                }
            }
        }
    }
    
    private func getSelectedWineType(value: Int) {
        var cumulativeTotal = 0
        let wineType = wineTypes.first { wineType in
            cumulativeTotal += Int(wineType.count)
            if value <= cumulativeTotal {
                SelectedWineType = wineType
                return true
            }
            return false
        }
    }
}


struct BreakSummary: Identifiable {
    let id = UUID()
    let type: String
    let count: Double
}

//
//  ExerciseLineChartView.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 16/9/24.
//

import SwiftUI
 
struct ExerciseBarChartView: View {
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var exerciseData: [ExerciseChartModel] = []
    @State private var currentActiveItem: ExerciseChartModel?
    @State private var plotWidth: CGFloat = 0
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "figure.mixed.cardio")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Exercise")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer(minLength: 80)
                
                Picker("", selection: $currentTab) {
                    Text("Week").tag("Week")
                    Text("Month").tag("Month")
                    Text("Year").tag("Year")
                }
                .pickerStyle(.segmented)
                .onChange(of: currentTab) { _, newValue in
                    fetchData(for: newValue)
                }
            }
                ExerciseBarChart(currentActiveItem: $currentActiveItem, plotWidth: $plotWidth, exerciseData: exerciseData, currentTab: $currentTab)
                    .padding()
        }
        .padding()
        .background(userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
        
            fetchData(for: currentTab)
            
            print("Fetched Exercise Data: \(String(describing: exerciseData))")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Exercise Chart")
    }
    
     
    private func fetchData(for period: String) {
        let dataFetcher = DataFetcher(modelContext: modelContext)
//        switch period {
//        case "Week":
//            exerciseData = dataFetcher.fetchLast7DaysBreakData()
//        case "Month":
//            exerciseData = dataFetcher.fetchLastMonthBreakData()
//        case "Year":
//            exerciseData = dataFetcher.fetchLastYearBreakData()
//        default:
//            exerciseData = dataFetcher.fetchLast7DaysBreakData()
//        }
    }
}

//#Preview {
//    ExerciseBarChartView()
//}

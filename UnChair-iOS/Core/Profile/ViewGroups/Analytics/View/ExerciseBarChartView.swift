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
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            //addSamples()
            fetchData(for: currentTab)
            
            print("Fetched Exercise Data: \(String(describing: exerciseData))")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Exercise Chart")
    }
    
    
//    private func addSamples() {
//        var sampleData: [ExerciseChartModel] = []
//        
//        // Loop over the past 365 days
//        for dayOffset in 0..<365 {
//            // Generate random values for each break type
//            let randomQuickBreak = Double.random(in: 3000...4000)
//            let randomShortBreak = Double.random(in: 2000...3000)
//            let randomMediumBreak = Double.random(in: 1000...2000)
//            let randomLongBreak = Double.random(in: 500...1000)
//            
//            // Create an array of BreakEntry instances
//            let breakEntries = [
//                BreakEntry(breakType: "Quick Break", breakValue: randomQuickBreak),
//                BreakEntry(breakType: "Short Break", breakValue: randomShortBreak),
//                BreakEntry(breakType: "Medium Break", breakValue: randomMediumBreak),
//                BreakEntry(breakType: "Long Break", breakValue: randomLongBreak)
//            ]
//            
//            // Calculate the date by subtracting the offset from the current date
//            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
//            
//            // Create a new ExerciseChartModel object
//            let sample = ExerciseChartModel(id: UUID().uuidString,
//                                            date: date,
//                                            breakEntries: breakEntries,
//                                            lastUpdated: Date(),
//                                            isSynced: false)
//            
//            // Append the sample to the array
//            sampleData.append(sample)
//        }
//        
//        // Sort the sampleData by date in ascending order (oldest to newest)
//        sampleData.sort { $0.date < $1.date }
//        
//        // Insert sorted samples into the model context
//        for sample in sampleData {
//            modelContext.insert(sample)
//        }
//        
//        do {
//            // Save the context after inserting all the samples
//            try modelContext.save()
//            print("Samples for the last 365 days added and sorted by date successfully.")
//        } catch {
//            print("Error saving samples: \(error)")
//        }
//    }
    
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

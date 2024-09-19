//
//  StepsBarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/8/24.
//

import SwiftUI

struct StepsBarChartView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var stepsData: [StepsChartModel] = []
    @State private var currentActiveItem: StepsChartModel?
    @State private var plotWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Steps")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    let totalValue = stepsData.reduce(into: 0.0) { (result, entry) in
                        result += Double(entry.steps)
                    }
                    
                    
                    Text("Avg \(totalValue.stringFormat) steps")
                        .font(.caption2)
                        .foregroundColor(.gray)
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
            
            StepsBarChart(currentActiveItem: $currentActiveItem, plotWidth: $plotWidth, stepsData: stepsData, currentTab: $currentTab)
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            // addSamples()
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Water Chart")
        
        
    }
    
    
    private func addSamples() {
        var sampleStepsData: [StepsChartModel] = []
        
        // Loop over the past 30 days
        for dayOffset in 0..<365 {
            // Generate a random water consumption between 1000ml and 3000ml
            let randomSteps = Int.random(in: 1000...2000)
            
            // Calculate the date by subtracting the offset from the current date
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            
            // Create a new WaterChartModel object
            let sample = StepsChartModel(id: UUID().uuidString,
                                         date: date,
                                         steps: randomSteps,
                                         lastUpdated: Date(),
                                         isSynced: false)
            
            // Append the sample to an array before inserting
            sampleStepsData.append(sample)
        }
        
        // Sort the sampleData by date in ascending order (oldest to newest)
        sampleStepsData.sort { $0.date < $1.date }
        
        // Insert sorted samples into the model context
        for sample in sampleStepsData {
            modelContext.insert(sample)
        }
        
        do {
            // Save the context after inserting all the samples
            try modelContext.save()
            print("Samples for the last 30 days added and sorted by date successfully.")
        } catch {
            print("Error saving samples: \(error)")
        }
    }
    
    private func fetchData(for period: String) {
        let dataFetcher = DataFetcher(modelContext: modelContext)
        switch period {
        case "Week":
            stepsData = dataFetcher.fetchLast7DaysStepsData()
        case "Month":
            stepsData = dataFetcher.fetchLastMonthStepsData()
        case "Year":
            stepsData = dataFetcher.fetchLastYearStepsData()
        default:
            stepsData = dataFetcher.fetchAllTimeStepsData()
        }
    }
}

#Preview {
    StepsBarChartView()
}

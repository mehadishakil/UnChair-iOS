//
//  SleepCapsuleChartView.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 15/9/24.
//


import SwiftUI
import SwiftData

struct SleepCapsuleChartView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var sleepData: [SleepChartModel] = []
    @State private var currentActiveItem: SleepChartModel?
    @State private var plotWidth: CGFloat = 0

    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Sleep")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    let totalValue = sleepData.reduce(0.0) { $0 + $1.sleep }
                    let average = totalValue / Double(sleepData.count)
                    
                    Text("Avg \(average.stringFormat) hrs")
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
            SleepCapsuleChart(sleepData: sleepData, currentTab: $currentTab)
                .frame(minHeight: 180)
                .padding()
        }
        .padding()
        .background(.ultraThinMaterial)
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
        var sampleData: [SleepChartModel] = []
        
        // Loop over the past 30 days
        for dayOffset in 0..<365 {
            // Generate a random water consumption between 1000ml and 3000ml
            let randomSleep = Double.random(in: 0...12)
            
            // Calculate the date by subtracting the offset from the current date
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            
            // Create a new WaterChartModel object
            let sample = SleepChartModel(id: UUID().uuidString,
                                         date: date,
                                         sleep: randomSleep,
                                         lastUpdated: Date(),
                                         isSynced: false)
            
            // Append the sample to an array before inserting
            sampleData.append(sample)
        }
        
        // Sort the sampleData by date in ascending order (oldest to newest)
        sampleData.sort { $0.date < $1.date }
        
        // Insert sorted samples into the model context
        for sample in sampleData {
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
            sleepData = dataFetcher.fetchLast7DaysSleepData()
        case "Month":
            sleepData = dataFetcher.fetchLastMonthSleepData()
        case "Year":
            sleepData = dataFetcher.fetchLastYearSleepData()
        default:
            sleepData = dataFetcher.fetchAllTimeSleepData()
        }
    }

}


extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999 {
            return String(format: "%.1fM", self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", self)
    }
}


#Preview {
    SleepCapsuleChartView()
}

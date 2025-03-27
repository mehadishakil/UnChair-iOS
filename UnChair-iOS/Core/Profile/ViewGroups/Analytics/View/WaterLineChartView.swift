//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

import SwiftUI
import SwiftData

struct WaterLineChartView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var waterData: [WaterChartModel] = []
    @State private var currentActiveItem: WaterChartModel?
    @State private var plotWidth: CGFloat = 0
    @StateObject private var firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "mug.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Water")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    let totalValue = waterData.reduce(0.0) { $0 + $1.consumption }
                    let average = totalValue / Double(waterData.count)
                    
                    Text("Avg \(average.stringFormat) ml")
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
            WaterLineChart(currentActiveItem: $currentActiveItem, plotWidth: $plotWidth, waterData: waterData, currentTab: $currentTab)
                .padding()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Water Chart")
    }
    
    
    private func addSamples() {
        var sampleData: [WaterChartModel] = []
        
        // Loop over the past 30 days
        for dayOffset in 0..<365 {
            // Generate a random water consumption between 1000ml and 3000ml
            let randomConsumption = Double.random(in: 1000...2000)
            
            // Calculate the date by subtracting the offset from the current date
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            
            // Create a new WaterChartModel object
            let sample = WaterChartModel(id: UUID().uuidString,
                                         date: date,
                                         consumption: randomConsumption)
            
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
        firestoreService.fetchWaterData { fetchedData in
            DispatchQueue.main.async {
                self.waterData = filterDataByPeriod(fetchedData, period: period)
            }
        }
    }
    
    private func filterDataByPeriod(_ data: [WaterChartModel], period: String) -> [WaterChartModel] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case "Week":
            return data.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        case "Month":
            return data.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case "Year":
            return data.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
        default:
            return data
        }
    }



}


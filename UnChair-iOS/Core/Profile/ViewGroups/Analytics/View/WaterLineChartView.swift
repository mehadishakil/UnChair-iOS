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
    
    private func fetchData(for period: String) {
        firestoreService.fetchWaterData(for: period) { fetchedData in
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
            // Get data from the last 7 days
            guard let oneWeekAgo = calendar.date(byAdding: .day, value: -6, to: now) else { return [] }
            return data.filter { $0.date >= oneWeekAgo && $0.date <= now }
            
        case "Month":
            // Get data from the last 30 days
            guard let oneMonthAgo = calendar.date(byAdding: .day, value: -29, to: now) else { return [] }
            return data.filter { $0.date >= oneMonthAgo && $0.date <= now }
            
        case "Year":
            // Get data from the last 365 days
            guard let oneYearAgo = calendar.date(byAdding: .day, value: -364, to: now) else { return [] }
            return data.filter { $0.date >= oneYearAgo && $0.date <= now }
            
        default:
            return data
        }
    }



}


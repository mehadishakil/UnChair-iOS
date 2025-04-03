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
                self.waterData = fetchedData
                print(waterData.count)
            }
        }
    }

}


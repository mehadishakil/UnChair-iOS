//
//  StepsBarChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 1/8/24.
//

import SwiftUI

struct StepsLineChartView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var stepsData: [StepsChartModel] = []
    @State private var currentActiveItem: StepsChartModel?
    @State private var plotWidth: CGFloat = 0
    @StateObject private var firestoreService = FirestoreService()
    
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
            
            StepsLineChart(currentActiveItem: $currentActiveItem, plotWidth: $plotWidth, stepsData: stepsData, currentTab: $currentTab)
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
            firestoreService.fetchStepsData { fetchedData in
                DispatchQueue.main.async {
                    self.stepsData = filterDataByPeriod(fetchedData, period: period)
                }
            }
        }
        
        private func filterDataByPeriod(_ data: [StepsChartModel], period: String) -> [StepsChartModel] {
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

#Preview {
    StepsLineChartView()
}

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
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "shoeprints.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Steps")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    let nonZeroData = stepsData.filter { $0.steps > 0 }
                    let totalValue = nonZeroData.reduce(0) { $0 + $1.steps }
                    let average = nonZeroData.isEmpty ? 0 : totalValue / nonZeroData.count
                    
                    
                    Text("Avg \(average) steps")
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
            if stepsData.isEmpty {
                Text("No data available")
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                StepsLineChart(
                    currentActiveItem: $currentActiveItem,
                    plotWidth: $plotWidth,
                    stepsData: stepsData,
                    currentTab: $currentTab
                )
                .frame(minHeight: 180)
            }
        }
        .padding()
        .background(
            userTheme == .system
            ? (colorScheme == .light ? .white : .darkGray)
                : (userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        )
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Steps Chart")
        
        
    }
    
    private func fetchData(for period: String) {
        firestoreService.fetchStepsData() { fetchedData in
            DispatchQueue.main.async {
                let filledData = fillMissingStepsDates(for: fetchedData, period: period)
                self.stepsData = filledData
            }
        }
    }
    
    private func fillMissingStepsDates(for data: [StepsChartModel], period: String) -> [StepsChartModel] {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        // Determine the start date based on the selected period.
        switch period {
        case "Week":
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
        case "Month":
            startDate = calendar.date(byAdding: .day, value: -29, to: now)!
        case "Year":
            startDate = calendar.date(byAdding: .day, value: -364, to: now)!
        default:
            startDate = data.first?.date ?? now
        }
        
        var completeData: [StepsChartModel] = []
        var currentDate = startDate
        
        // Loop through each day in the range.
        while currentDate <= now {
            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completeData.append(existing)
            } else {
                // If no data exists for this day, create a default record.
                completeData.append(StepsChartModel(date: currentDate, steps: 0))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Ensure the final data is sorted.
        completeData.sort { $0.date < $1.date }
        return completeData
    }
    
}

#Preview {
    StepsLineChartView()
}

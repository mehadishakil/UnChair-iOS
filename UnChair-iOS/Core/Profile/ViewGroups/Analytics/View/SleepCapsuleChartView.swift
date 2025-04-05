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
    @StateObject private var firestoreService = FirestoreService()

    
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
                .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Sleep Chart")
    }
    
    private func fetchData(for period: String) {
        firestoreService.fetchSleepData() { fetchedData in
            DispatchQueue.main.async {
                // CHANGE: First filter the data, then fill missing dates
                let filteredData = filterDataByPeriod(fetchedData, period: period)
                self.sleepData = fillMissingSleepDates(for: filteredData, period: period)
            }
        }
    }
    
    
    private func fillMissingSleepDates(for data: [SleepChartModel], period: String) -> [SleepChartModel] {
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
        
        var completeData: [SleepChartModel] = []
        var currentDate = startDate
        
        // Loop through each day in the range.
        while currentDate <= now {
            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completeData.append(existing)
            } else {
                // If no data exists for this day, create a default record.
                completeData.append(SleepChartModel(date: currentDate, sleep: 0))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Ensure the final data is sorted.
        completeData.sort { $0.date < $1.date }
        return completeData
    }
    
    
    private func filterDataByPeriod(_ data: [SleepChartModel], period: String) -> [SleepChartModel] {
        let calendar = Calendar.current
        let now = Date()
        
        return data.filter { dataPoint in
            switch period {
            case "Week":
                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 6
            case "Month":
                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 29
            case "Year":
                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 364
            default:
                return true
            }
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

//
//  MeditationLollipopChartView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 8/4/25.
//

import SwiftUI
import SwiftData

struct MeditationLollipopChartView: View {
    @State private var currentTab: String = "Week"
    @State private var meditationData: [MeditationChartModel] = []
    @State private var currentActiveItem: MeditationChartModel?
    @State private var plotWidth: CGFloat = 0
    @StateObject private var firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Meditation")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    // Calculate average of non-zero values only
                    let nonZeroData = meditationData.filter { $0.duration > 0 }
                    let totalValue = nonZeroData.reduce(0.0) { $0 + $1.duration }
                    let average = nonZeroData.isEmpty ? 0 : totalValue / Double(nonZeroData.count)
                    
                    Text("Avg \(average, specifier: "%.1f") min")
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
            
            if meditationData.isEmpty {
                Text("No meditation data available")
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                MeditationLollipopChart(
                    currentActiveItem: $currentActiveItem,
                    plotWidth: $plotWidth,
                    meditationData: meditationData,
                    currentTab: $currentTab
                )
                .frame(minHeight: 180)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func fetchData(for period: String) {
        firestoreService.fetchMeditationData() { fetchedData in
            DispatchQueue.main.async {
                let filledData = fillMissingMeditationDates(for: fetchedData, period: period)
                self.meditationData = filledData
            }
        }
    }
    
    private func fillMissingMeditationDates(for data: [MeditationChartModel], period: String) -> [MeditationChartModel] {
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
        
        var completeData: [MeditationChartModel] = []
        var currentDate = startDate
        
        // Loop through each day in the range.
        while currentDate <= now {
            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completeData.append(existing)
            } else {
                // If no data exists for this day, create a default record.
                completeData.append(MeditationChartModel(id: UUID().uuidString, date: currentDate, duration: 0))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Ensure the final data is sorted.
        completeData.sort { $0.date < $1.date }
        return completeData
    }
}

#Preview {
    MeditationLollipopChartView()
}

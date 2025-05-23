//
//  ContentView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/7/24.
//

//import SwiftUI
//import SwiftData
//
//struct WaterBarChartView: View {
//    
//    @Environment(\.modelContext) var modelContext
//    @State private var currentTab: String = "Week"
//    @State private var waterData: [WaterChartModel] = []
//    @State private var currentActiveItem: WaterChartModel?
//    @State private var plotWidth: CGFloat = 0
//    @StateObject private var firestoreService = FirestoreService()
//    
//    var body: some View {
//        VStack {
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    HStack {
//                        Image(systemName: "mug.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 20)
//                            .foregroundColor(.blue)
//                        Text("Water")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                    }
//                    let totalValue = waterData.reduce(0.0) { $0 + $1.consumption }
//                    let average = totalValue / Double(waterData.count)
//                    
//                    Text("Avg \(average.stringFormat) ml")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer(minLength: 80)
//                
//                Picker("", selection: $currentTab) {
//                    Text("Week").tag("Week")
//                    Text("Month").tag("Month")
//                    Text("Year").tag("Year")
//                }
//                .pickerStyle(.segmented)
//                .onChange(of: currentTab) { _, newValue in
//                    fetchData(for: newValue)
//                }
//            }
//            WaterBarChart(currentActiveItem: $currentActiveItem, plotWidth: $plotWidth, waterData: waterData, currentTab: $currentTab)
//                .padding()
//            
//            
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//        .shadow(radius: 8)
//        .onAppear {
//            fetchData(for: currentTab)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .navigationTitle("Water Chart")
//    }
//    
//    private func fetchData(for period: String) {
//        firestoreService.fetchWaterData() { fetchedData in
//            DispatchQueue.main.async {
//                // CHANGE: First filter the data, then fill missing dates
//                let filteredData = filterDataByPeriod(fetchedData, period: period)
//                self.waterData = fillMissingWaterDates(for: filteredData, period: period)
//            }
//        }
//    }
//    
//    
//    private func fillMissingWaterDates(for data: [WaterChartModel], period: String) -> [WaterChartModel] {
//        let calendar = Calendar.current
//        let now = Date()
//        var startDate: Date
//        
//        // Determine the start date based on the selected period.
//        switch period {
//        case "Week":
//            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
//        case "Month":
//            startDate = calendar.date(byAdding: .day, value: -29, to: now)!
//        case "Year":
//            startDate = calendar.date(byAdding: .day, value: -364, to: now)!
//        default:
//            startDate = data.first?.date ?? now
//        }
//        
//        var completeData: [WaterChartModel] = []
//        var currentDate = startDate
//        
//        // Loop through each day in the range.
//        while currentDate <= now {
//            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
//                completeData.append(existing)
//            } else {
//                // If no data exists for this day, create a default record.
//                completeData.append(WaterChartModel(date: currentDate, consumption: 0))
//            }
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
//        }
//        
//        // Ensure the final data is sorted.
//        completeData.sort { $0.date < $1.date }
//        return completeData
//    }
//    
//    private func filterDataByPeriod(_ data: [WaterChartModel], period: String) -> [WaterChartModel] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        return data.filter { dataPoint in
//            switch period {
//            case "Week":
//                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
//                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 6
//            case "Month":
//                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
//                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 29
//            case "Year":
//                return calendar.isDate(dataPoint.date, inSameDayAs: now) ||
//                calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? 0 <= 364
//            default:
//                return true
//            }
//        }
//    }
//
//}
//












//
//
//import SwiftUI
//import SwiftData
//
//struct WaterBarChartView: View {
//    @StateObject private var firestoreService = FirestoreService()
//    @State private var currentTab: String = "Week"
//    @State private var waterData: [WaterChartModel] = []
//    @State private var currentActiveItem: WaterChartModel?
//    @State private var plotWidth: CGFloat = 0
//    
//    var body: some View {
//        VStack {
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    HStack {
//                        Image(systemName: "mug.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 20)
//                            .foregroundColor(.blue)
//                        Text("Water")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                    }
//                    let totalValue = waterData.reduce(0.0) { $0 + $1.consumption }
//                    let average = waterData.isEmpty ? 0 : totalValue / Double(waterData.count)
//                    
//                    Text("Avg \(Int(average)) ml")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer(minLength: 80)
//                
//                Picker("", selection: $currentTab) {
//                    Text("Week").tag("Week")
//                    Text("Month").tag("Month")
//                    Text("Year").tag("Year")
//                }
//                .pickerStyle(.segmented)
//                .onChange(of: currentTab) { _, newValue in
//                    fetchData(for: newValue)
//                }
//            }
//            
//            WaterBarChart(
//                currentActiveItem: $currentActiveItem,
//                plotWidth: $plotWidth,
//                waterData: waterData,
//                currentTab: $currentTab
//            )
//            .padding()
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//        .shadow(radius: 8)
//        .onAppear {
//            fetchData(for: currentTab)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .navigationTitle("Water Chart")
//    }
//    
//    private func fetchData(for period: String) {
//        firestoreService.fetchWaterData() { fetchedData in
//            DispatchQueue.main.async {
//                // First filter the data, then fill missing dates
//                let filteredData = filterDataByPeriod(fetchedData, period: period)
//                self.waterData = fillMissingWaterDates(for: filteredData, period: period)
//            }
//        }
//    }
//    
//    private func fillMissingWaterDates(for data: [WaterChartModel], period: String) -> [WaterChartModel] {
//        let calendar = Calendar.current
//        let now = Date()
//        var startDate: Date
//        
//        // Determine the start date based on the selected period
//        switch period {
//        case "Week":
//            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
//        case "Month":
//            startDate = calendar.date(byAdding: .day, value: -29, to: now)!
//        case "Year":
//            startDate = calendar.date(byAdding: .day, value: -364, to: now)!
//        default:
//            startDate = data.first?.date ?? now
//        }
//        
//        var completeData: [WaterChartModel] = []
//        var currentDate = startDate
//        
//        // Loop through each day in the range
//        while currentDate <= now {
//            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
//                completeData.append(existing)
//            } else {
//                // If no data exists for this day, create a default record
//                completeData.append(WaterChartModel(date: currentDate, consumption: 0))
//            }
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
//        }
//        
//        // Ensure the final data is sorted
//        completeData.sort { $0.date < $1.date }
//        return completeData
//    }
//    
//    private func filterDataByPeriod(_ data: [WaterChartModel], period: String) -> [WaterChartModel] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        return data.filter { dataPoint in
//            switch period {
//            case "Week":
//                // Within last 7 days
//                return calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? Int.max <= 6
//            case "Month":
//                // Within last 30 days
//                return calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? Int.max <= 29
//            case "Year":
//                // Within last 365 days
//                return calendar.dateComponents([.day], from: dataPoint.date, to: now).day ?? Int.max <= 364
//            default:
//                return true
//            }
//        }
//    }
//}
//
//// Creating the chart model protocol implementation
//extension WaterChartModel: Equatable {
//    static func == (lhs: WaterChartModel, rhs: WaterChartModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//}





import SwiftUI
import SwiftData

struct WaterBarChartView: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var waterData: [WaterChartModel] = []
    @State private var currentActiveItem: WaterChartModel?
    @State private var plotWidth: CGFloat = 0
    @StateObject private var firestoreService = FirestoreService()
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Water")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Calculate average of non-zero values only
                    let nonZeroData = waterData.filter { $0.consumption > 0 }
                    let totalValue = nonZeroData.reduce(0.0) { $0 + $1.consumption }
                    let average = nonZeroData.isEmpty ? 0 : totalValue / Double(nonZeroData.count)
                    
                    Text("Avg \(average, specifier: "%.1f") ml")
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
            
            if waterData.isEmpty {
                Text("No data available")
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                WaterBarChart(
                    currentActiveItem: $currentActiveItem,
                    plotWidth: $plotWidth,
                    waterData: waterData,
                    currentTab: $currentTab
                )
                .frame(minHeight: 180)
            }
        }
        .padding()
        .background(userTheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            fetchData(for: currentTab)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Water Intake")
    }
    
    private func fetchData(for period: String) {
        firestoreService.fetchWaterData() { fetchedData in
            DispatchQueue.main.async {
                let filledData = fillMissingWaterDates(for: fetchedData, period: period)
                self.waterData = filledData
            }
        }
    }
    
    private func fillMissingWaterDates(for data: [WaterChartModel], period: String) -> [WaterChartModel] {
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
        
        var completeData: [WaterChartModel] = []
        var currentDate = startDate
        
        // Loop through each day in the range.
        while currentDate <= now {
            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completeData.append(existing)
            } else {
                // If no data exists for this day, create a default record.
                completeData.append(WaterChartModel(date: currentDate, consumption: 0))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Ensure the final data is sorted.
        completeData.sort { $0.date < $1.date }
        return completeData
    }
}

#Preview {
    WaterBarChartView()
}

//
//  DataFetcher.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 11/9/24.
//

import SwiftUI
import SwiftData

class DataFetcher: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchLast7DaysData() -> [WaterChartModel] {
        let today = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        // Use precomputed date in the predicate
        let predicate = #Predicate { (entry: WaterChartModel) in
            entry.date >= sevenDaysAgo && entry.date <= today
        }

        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
        do {
            let results = try modelContext.fetch(request)

            // Aggregate data by day
            let aggregatedData = Dictionary(grouping: results) { result in
                // Use the date without time components for grouping by day
                Calendar.current.startOfDay(for: result.date) ?? Date()
            }.map { (date, entries) in
                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
                let averageConsumption = totalConsumption / Double(entries.count)
                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
            }.sorted { $0.date < $1.date }
            
            return aggregatedData
        } catch {
            print("Error fetching last 7 days data: \(error)")
            return []
        }
    }

    
    func fetchLastMonthData() -> [WaterChartModel] {
        let today = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today)!

        // Use precomputed date in the predicate
        let predicate = #Predicate { (entry: WaterChartModel) in
            entry.date >= oneMonthAgo && entry.date <= today
        }

        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
        do {
            let results = try modelContext.fetch(request)

            // Aggregate data by week
            let aggregatedData = Dictionary(grouping: results) { result in
                Calendar.current.startOfWeek(for: result.date) ?? Date()
            }.map { (date, entries) in
                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
                let averageConsumption = totalConsumption / Double(entries.count)
                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
            }.sorted { $0.date < $1.date }
            
            return aggregatedData
        } catch {
            print("Error fetching last month's data: \(error)")
            return []
        }
    }

    
    func fetchLastYearData() -> [WaterChartModel] {
        let today = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!

        let predicate = #Predicate { (entry: WaterChartModel) in
            entry.date >= oneYearAgo && entry.date <= today
        }

        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
        do {
            let results = try modelContext.fetch(request)
            
            // Aggregate data by month
            let aggregatedData = Dictionary(grouping: results) { result in
                Calendar.current.startOfMonth(for: result.date) ?? Date()
            }.map { (date, entries) in
                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
                let averageConsumption = totalConsumption / Double(entries.count)
                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
            }.sorted { $0.date < $1.date }
            
            return aggregatedData
        } catch {
            print("Error fetching last year's data: \(error)")
            return []
        }
    }

    
    func fetchAllTimeData() -> [WaterChartModel] {
        let today = Date()  // Precompute current date
        
        // Use precomputed date in the predicate
        let predicate = #Predicate { (entry: WaterChartModel) in
            entry.date <= today
        }
        
        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
        do {
            let results = try modelContext.fetch(request)
            return results
        } catch {
            print("Error fetching all-time data: \(error)")
            return []
        }
    }
}


extension Calendar {
    func startOfMonth(for date: Date) -> Date? {
        return self.date(from: self.dateComponents([.year, .month], from: date))
    }
    
    func startOfWeek(for date: Date) -> Date? {
            let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return self.date(from: components)
    }
    
    func startOfDay(for date: Date) -> Date? {
            return self.date(from: self.dateComponents([.year, .month, .day], from: date))
    }
}

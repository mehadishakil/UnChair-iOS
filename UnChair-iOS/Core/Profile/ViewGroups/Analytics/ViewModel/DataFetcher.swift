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
    var now: Date
    var yesterday: Date
    var sevenDaysAgo: Date
    var oneMonthAgo: Date
    var oneYearAgo: Date
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initialize the properties
        self.now = Date.now
        self.yesterday = Date.now.addingTimeInterval(-86400)
        self.sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: self.yesterday)!
        self.oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: self.yesterday)!
        self.oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: self.yesterday)!
    }
    
//    func fetchLast7DaysWaterData() -> [WaterChartModel] {
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: WaterChartModel) in
//            entry.date >= sevenDaysAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by day
//            let aggregatedData = Dictionary(grouping: results) { result in
//                // Use the date without time components for grouping by day
//                Calendar.current.startOfDay(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
//                // let averageConsumption = totalConsumption / Double(entries.count)
//                return WaterChartModel(id: UUID().uuidString, date: date, consumption: totalConsumption, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last 7 days water data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLastMonthWaterData() -> [WaterChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: WaterChartModel) in
//            entry.date >= oneMonthAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by week
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfWeek(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
//                let averageConsumption = totalConsumption / Double(entries.count)
//                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last month's water data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLastYearWaterData() -> [WaterChartModel] {
//        
//        let predicate = #Predicate { (entry: WaterChartModel) in
//            entry.date >= oneYearAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by month
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfMonth(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let totalConsumption = entries.reduce(0) { $0 + $1.consumption }
//                let averageConsumption = totalConsumption / Double(entries.count)
//                return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last year's water data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchAllTimeWaterData() -> [WaterChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: WaterChartModel) in
//            entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<WaterChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            return results
//        } catch {
//            print("Error fetching all-time water data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLast7DaysStepsData() -> [StepsChartModel] {
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: StepsChartModel) in
//            entry.date >= sevenDaysAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<StepsChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by day
//            let aggregatedData = Dictionary(grouping: results) { result in
//                // Use the date without time components for grouping by day
//                Calendar.current.startOfDay(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let dailyTotalSteps = entries.reduce(0) { $0 + $1.steps }
//                // let averageSteps = (Double) totalSteps / (Double) entries.count
//                // return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
//                return StepsChartModel(id: UUID().uuidString, date: date, steps: dailyTotalSteps, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last 7 days steps data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLastMonthStepsData() -> [StepsChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: StepsChartModel) in
//            entry.date >= oneMonthAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<StepsChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by week
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfWeek(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let dailyTotalSteps = entries.reduce(0) { $0 + $1.steps }
//                let averageSteps = dailyTotalSteps / entries.count
//                return StepsChartModel(id: UUID().uuidString, date: date, steps: averageSteps, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last month's steps data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLastYearStepsData() -> [StepsChartModel] {
//        
//        let predicate = #Predicate { (entry: StepsChartModel) in
//            entry.date >= oneYearAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<StepsChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by month
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfMonth(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let dailyTotalSteps = entries.reduce(0) { $0 + $1.steps }
//                let averageSteps = dailyTotalSteps / entries.count
//                return StepsChartModel(id: UUID().uuidString, date: date, steps: averageSteps, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last year's steps data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchAllTimeStepsData() -> [StepsChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: StepsChartModel) in
//            entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<StepsChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            return results
//        } catch {
//            print("Error fetching all-time water data: \(error)")
//            return []
//        }
//    }
//    
//    
//    func fetchLast7DaysSleepData() -> [SleepChartModel] {
//    // Use precomputed date in the predicate
//    let predicate = #Predicate { (entry: SleepChartModel) in
//        entry.date >= sevenDaysAgo && entry.date <= yesterday
//    }
//    
//    let request = FetchDescriptor<SleepChartModel>(predicate: predicate)
//    do {
//        let results = try modelContext.fetch(request)
//        
//        // Aggregate data by day
//        let aggregatedData = Dictionary(grouping: results) { result in
//            // Use the date without time components for grouping by day
//            Calendar.current.startOfDay(for: result.date) ?? Date()
//        }.map { (date, entries) in
//            let dailyTotalSleep = entries.reduce(0) { $0 + $1.sleep }
//            // let averageSteps = (Double) totalSteps / (Double) entries.count
//            // return WaterChartModel(id: UUID().uuidString, date: date, consumption: averageConsumption, lastUpdated: date)
//            return SleepChartModel(id: UUID().uuidString, date: date, sleep: dailyTotalSleep, lastUpdated: date)
//        }.sorted { $0.date < $1.date }
//        
//        return aggregatedData
//    } catch {
//        print("Error fetching last 7 days sleep data: \(error)")
//        return []
//    }
//}
//
//
//    func fetchLastMonthSleepData() -> [SleepChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: SleepChartModel) in
//            entry.date >= oneMonthAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<SleepChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by week
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfWeek(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let dailyTotalSleep = entries.reduce(0) { $0 + $1.sleep }
//                let averageSleep = dailyTotalSleep / Double(entries.count)
//                return SleepChartModel(id: UUID().uuidString, date: date, sleep: averageSleep, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last month's sleep data: \(error)")
//            return []
//        }
//    }
//
//
//    func fetchLastYearSleepData() -> [SleepChartModel] {
//        
//        let predicate = #Predicate { (entry: SleepChartModel) in
//            entry.date >= oneYearAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<SleepChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by month
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.startOfMonth(for: result.date) ?? Date()
//            }.map { (date, entries) in
//                let dailyTotalSleep = entries.reduce(0) { $0 + $1.sleep }
//                let averageSleep = dailyTotalSleep / Double(entries.count)
//                return SleepChartModel(id: UUID().uuidString, date: date, sleep: averageSleep, lastUpdated: date)
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            print("Error fetching last year's sleep data: \(error)")
//            return []
//        }
//    }
//
//
//    func fetchAllTimeSleepData() -> [SleepChartModel] {
//        
//        // Use precomputed date in the predicate
//        let predicate = #Predicate { (entry: SleepChartModel) in
//            entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<SleepChartModel>(predicate: predicate)
//        do {
//            let results = try modelContext.fetch(request)
//            return results
//        } catch {
//            print("Error fetching all-time sleep data: \(error)")
//            return []
//        }
//    }
//        
//    
//    //    func fetchLast7DaysExerciseData() -> [ExerciseChartModel] {
//    //    // Use precomputed date in the predicate
//    //    let predicate = #Predicate { (entry: ExerciseChartModel) in
//    //        entry.date >= sevenDaysAgo && entry.date <= yesterday
//    //    }
//    //    
//    //    let request = FetchDescriptor<ExerciseChartModel>(predicate: predicate)
//    //    do {
//    //        let results = try modelContext.fetch(request)
//    //        
//    //        // Aggregate data by day
//    //        let aggregatedData = Dictionary(grouping: results) { result in
//    //            Calendar.current.startOfDay(for: result.date) ?? Date()
//    //        }.map { (date, entries) in
//    //            let quickBreak = entries.reduce(0) { $0 + $1.breaks.quickBreak }
//    //            let shortBreak = entries.reduce(0) { $0 + $1.breaks.shortBreak }
//    //            let mediumBreak = entries.reduce(0) { $0 + $1.breaks.mediumBreak }
//    //            let longBreak = entries.reduce(0) { $0 + $1.breaks.longBreak }
//    //            
//    //            let averageQuickBreak = quickBreak / Double(entries.count)
//    //            let averageShortBreak = shortBreak / Double(entries.count)
//    //            let averageMediumBreak = mediumBreak / Double(entries.count)
//    //            let averageLongBreak = longBreak / Double(entries.count)
//    //            
//    //            return ExerciseChartModel(id: UUID().uuidString, date: date, breaks: Breaks(quickBreak: averageQuickBreak, shortBreak: averageShortBreak, mediumBreak: averageMediumBreak, longBreak: averageLongBreak), lastUpdated: date)
//    //        }.sorted { $0.date < $1.date }
//    //        
//    //        return aggregatedData
//    //    } catch {
//    //        print("Error fetching last 7 days exercise data: \(error)")
//    //        return []
//    //    }
//    //}
//
//    
//    func fetchLast7DaysBreakData() -> [ExerciseChartModel] {
//        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//        
//        let predicate = #Predicate<ExerciseChartModel> { entry in
//            entry.date >= sevenDaysAgo && entry.date <= yesterday
//        }
//        
//        let request = FetchDescriptor<ExerciseChartModel>(predicate: predicate)
//        do {
//                // Fetch the data from the model context
//                let results = try modelContext.fetch(request)
//                
//                // Return the raw data entries
//                return results
//            } catch {
//                // Handle any errors that occur during fetching
//                print("Error fetching last 7 days exercise data: \(error)")
//                return []
//            }
//    }
//        
//    
//    func fetchLastMonthBreakData() -> [ExerciseChartModel] {
//        // Define the date range for the last month
//        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//        
//        // Create a predicate to filter entries within the last month up to yesterday
//        let predicate = #Predicate<ExerciseChartModel> { entry in
//            entry.date >= oneMonthAgo && entry.date <= yesterday
//        }
//        
//        // Create a fetch request with the predicate
//        let request = FetchDescriptor<ExerciseChartModel>(predicate: predicate)
//        
//        do {
//            // Fetch the data from the model context
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by week
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: result.date)) ?? Date()
//            }.map { (date, entries) in
//                // Collect all break entries for the week
//                let allBreakEntries = entries.flatMap { $0.breakEntries }
//                
//                // Compute weekly average of break values per entry type
//                let breakEntriesByType = Dictionary(grouping: allBreakEntries) { $0.breakType }
//                let weeklyAverageBreakEntries = breakEntriesByType.map { (breakType, entries) in
//                    let averageValue = entries.reduce(0) { $0 + $1.breakValue } / Double(entries.count)
//                    return BreakEntry(breakType: breakType, breakValue: averageValue)
//                }
//                
//                return ExerciseChartModel(
//                    id: UUID().uuidString,
//                    date: date,
//                    breakEntries: weeklyAverageBreakEntries,
//                    lastUpdated: date
//                )
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            // Handle any errors that occur during fetching
//            print("Error fetching last month's exercise data: \(error)")
//            return []
//        }
//    }
//        
//    
//    func fetchLastYearBreakData() -> [ExerciseChartModel] {
//        // Define the date range for the last year
//        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//        
//        // Create a predicate to filter entries within the last year up to yesterday
//        let predicate = #Predicate<ExerciseChartModel> { entry in
//            entry.date >= oneYearAgo && entry.date <= yesterday
//        }
//        
//        // Create a fetch request with the predicate
//        let request = FetchDescriptor<ExerciseChartModel>(predicate: predicate)
//        
//        do {
//            // Fetch the data from the model context
//            let results = try modelContext.fetch(request)
//            
//            // Aggregate data by month
//            let aggregatedData = Dictionary(grouping: results) { result in
//                Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: result.date)) ?? Date()
//            }.map { (date, entries) in
//                // Collect all break entries for the month
//                let allBreakEntries = entries.flatMap { $0.breakEntries }
//                
//                // Compute monthly average of break values per entry type
//                let breakEntriesByType = Dictionary(grouping: allBreakEntries) { $0.breakType }
//                let monthlyAverageBreakEntries = breakEntriesByType.map { (breakType, entries) in
//                    let averageValue = entries.reduce(0) { $0 + $1.breakValue } / Double(entries.count)
//                    return BreakEntry(breakType: breakType, breakValue: averageValue)
//                }
//                
//                return ExerciseChartModel(
//                    id: UUID().uuidString,
//                    date: date,
//                    breakEntries: monthlyAverageBreakEntries,
//                    lastUpdated: date
//                )
//            }.sorted { $0.date < $1.date }
//            
//            return aggregatedData
//        } catch {
//            // Handle any errors that occur during fetching
//            print("Error fetching last year's exercise data: \(error)")
//            return []
//        }
//    }
//        
//    
//    func fetchAllTimeBreakData() -> [ExerciseChartModel] {
//            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//            
//            let predicate = #Predicate<ExerciseChartModel> { entry in
//                entry.date <= yesterday
//            }
//            
//            let request = FetchDescriptor<ExerciseChartModel>(predicate: predicate)
//            do {
//                let results = try modelContext.fetch(request)
//                return results.sorted { $0.date < $1.date }
//            } catch {
//                print("Error fetching all-time exercise data: \(error)")
//                return []
//            }
//        }

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


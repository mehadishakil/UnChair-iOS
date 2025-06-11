//
//  MultiLineChart.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 31/7/24.
//
//

//import SwiftUI
//import Charts
//
//struct ExerciseMultiLineChartView: View {
//    @State private var selectedCity = 0
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            HStack{
//                Image(systemName: "figure.mixed.cardio")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 20)
//                    .foregroundColor(.blue)
//                Text("Breaks")
//                    .fontWeight(.semibold)
//                    .foregroundColor(.blue)
//            }
//            
//            Text("Avg 45 min")
//                .font(.caption2)
//                .foregroundColor(.gray)
//            
//            ChartContentView(selectedCity: $selectedCity)
//                .padding()
//        }
//        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 900, alignment: .top)
//        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(radius: 8)
//        
//        
//    }
//    
//    
//}
//
//struct ChartContentView: View {
//    @Binding var selectedCity: Int
//    @State private var tappedCity: String?
//    
//    var body: some View {
//        Chart {
//            ForEach(CityWeatherData.cityRain, id:\.city) { city in
//                ForEach(city.data) { weather in
//                    LineMark(
//                        x: .value("Month", weather.month),
//                        y: .value("Rainfall", weather.value)
//                    )
//                    .interpolationMethod(.catmullRom)
//                    .lineStyle(StrokeStyle(lineWidth: city.city == tappedCity ? 4.0 : 2.0))
//
//                    PointMark(
//                        x: .value("Month", weather.month),
//                        y: .value("Rainfall", weather.value)
//                    )
//                    .symbolSize(city.city == tappedCity ? 100 : 50)
//                }
//                .foregroundStyle(by: .value("City", city.city))
//            }
//        }
//        .chartForegroundStyleScale([
//            CityWeatherData.citydata[0].0 : CityWeatherData.citydata[0].2,
//            CityWeatherData.citydata[1].0 : CityWeatherData.citydata[1].2,
//            CityWeatherData.citydata[2].0 : CityWeatherData.citydata[2].2,
//            CityWeatherData.citydata[3].0 : CityWeatherData.citydata[3].2,
//        ])
//        .chartSymbolScale([
//            "New York": Circle().strokeBorder(lineWidth: tappedCity == "New York" ? 4 : 2),
//            "Amsterdam": Circle().strokeBorder(lineWidth: tappedCity == "Amsterdam" ? 4 : 2),
//            "London": Circle().strokeBorder(lineWidth: tappedCity == "London" ? 4 : 2),
//            "Toronto": Circle().strokeBorder(lineWidth: tappedCity == "Toronto" ? 4 : 2),
//        ])
//        .chartOverlay { proxy in
//            GeometryReader { geo in
//                chartOverlay(proxy: proxy, geo: geo)
//            }
//        }
//    }
//    
//    func chartOverlay(proxy: ChartProxy, geo: GeometryProxy) -> some View {
//        Rectangle().fill(.clear).contentShape(Rectangle())
//            .simultaneousGesture(
//                DragGesture(minimumDistance: 0)
//                    .onEnded { value in
//                        let location = value.location
//                        
//                        var closestCity: String?
//                        var minDistance: CGFloat = .infinity
//                        
//                        for cityData in CityWeatherData.cityRain {
//                            for weather in cityData.data {
//                                if let xPosition = proxy.position(forX: weather.month) {
//                                    if let yPosition = proxy.position(forY: weather.value) {
//                                        let point = CGPoint(x: xPosition, y: yPosition)
//                                        let currentDistance = distance(from: location, to: point)
//                                        if currentDistance < minDistance {
//                                            minDistance = currentDistance
//                                            closestCity = cityData.city
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        tappedCity = closestCity
//                    }
//            )
//    }
//    
//    private func distance(from point: CGPoint, to linePoint: CGPoint) -> CGFloat {
//        return sqrt(pow(point.x - linePoint.x, 2) + pow(point.y - linePoint.y, 2))
//    }
//}
//
//#Preview {
//    ExerciseMultiLineChartView()
//}



//struct ExerciseMultiLineChartView: View {
//    
//    @Environment(\.modelContext) var modelContext
//    @State private var currentTab: String = "Week"
//    @State private var exerciseData: [ExerciseChartModel] = []
//    @State private var currentActiveItem: ExerciseChartModel?
//    @State private var plotWidth: CGFloat = 0
//    @StateObject private var firestoreService = FirestoreService()
//    
//    var body: some View {
//        VStack {
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    HStack {
//                        Image(systemName: "drop.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 20)
//                            .foregroundColor(.blue)
//                        Text("Water")
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                    }
//                    
//                    // Calculate average of non-zero values only
////                    let nonZeroData = waterData.filter { $0.consumption > 0 }
////                    let totalValue = nonZeroData.reduce(0.0) { $0 + $1.consumption }
////                    let average = nonZeroData.isEmpty ? 0 : totalValue / Double(nonZeroData.count)
////                    
////                    Text("Avg \(average, specifier: "%.1f") ml")
////                        .font(.caption2)
////                        .foregroundColor(.gray)
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
//            if exerciseData.isEmpty {
//                Text("No data available")
//                    .frame(height: 180)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//            } else {
//                ExerciseMultiLineChart(
//                    currentActiveItem: $currentActiveItem,
//                    plotWidth: $plotWidth,
//                    exerciseData: exerciseData,
//                    currentTab: $currentTab
//                )
//                .frame(minHeight: 180)
//            }
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//        .shadow(radius: 8)
//        .onAppear {
//            fetchData(for: currentTab)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .navigationTitle("Water Intake")
//    }
//    
//    private func fetchData(for period: String) {
//        firestoreService.fetchExerciseData() { fetchedData in
//            DispatchQueue.main.async {
//                let filledData = fillMissingExerciseDates(for: fetchedData, period: period)
//                self.exerciseData = filledData
//            }
//        }
//    }
//    
//    private func fillMissingExerciseDates(for data: [ExerciseChartModel], period: String) -> [ExerciseChartModel] {
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
//        var completeData: [ExerciseChartModel] = []
//        var currentDate = startDate
//        
//        // Loop through each day in the range.
//        while currentDate <= now {
//            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
//                completeData.append(existing)
//            } else {
//                // If no data exists for this day, create a default record.
//                completeData.append(ExerciseChartModel(date: currentDate, ))
//            }
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
//        }
//        
//        // Ensure the final data is sorted.
//        completeData.sort { $0.date < $1.date }
//        return completeData
//    }
//}

import SwiftUI
import SwiftData

struct ExerciseMultiLineChartView: View {
    @Environment(\.modelContext) var modelContext
    @State private var currentTab: String = "Week"
    @State private var exerciseData: [ExerciseChartModel] = []
    @State private var currentActiveItem: ExerciseChartModel?
    @State private var plotWidth: CGFloat = 0
    @StateObject private var firestoreService = FirestoreService()
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "figure.mixed.cardio")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(.blue)
                        Text("Exercise")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
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
            
            if exerciseData.isEmpty {
                Text("No data available")
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                ExerciseMultiLineChart(
                    currentActiveItem: $currentActiveItem,
                    plotWidth: $plotWidth,
                    exerciseData: exerciseData,
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
        .navigationTitle("Exercise Data")
    }
    
    private func fetchData(for period: String) {
        firestoreService.fetchExerciseData { fetchedData in
            DispatchQueue.main.async {
                let filledData = fillMissingExerciseDates(for: fetchedData, period: period)
                self.exerciseData = filledData
                print("data size is \(exerciseData.count)")
            }
        }
    }
    
    private func fillMissingExerciseDates(for data: [ExerciseChartModel], period: String) -> [ExerciseChartModel] {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        // Get all unique break types from the existing data
        let allBreakTypes = getAllBreakTypes(from: data)
        
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
        
        var completeData: [ExerciseChartModel] = []
        var currentDate = startDate
        
        // Loop through each day in the range.
        while currentDate <= now {
            if let existing = data.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                // Make sure all break types are represented
                let existingBreakTypes = Set(existing.breakEntries.map { $0.breakType })
                var updatedBreakEntries = existing.breakEntries
                
                // Add missing break types with value 0
                for breakType in allBreakTypes {
                    if !existingBreakTypes.contains(breakType) {
                        updatedBreakEntries.append(BreakEntry(breakType: breakType, breakValue: 0))
                    }
                }
                
                let updatedModel = ExerciseChartModel(
                    id: existing.id,
                    date: existing.date,
                    breakEntries: updatedBreakEntries
                )
                completeData.append(updatedModel)
            } else {
                // Create a default record with all break types at value 0
                let defaultBreakEntries = allBreakTypes.map { BreakEntry(breakType: $0, breakValue: 0) }
                completeData.append(ExerciseChartModel(
                    id: "default-\(currentDate.timeIntervalSince1970)",
                    date: currentDate,
                    breakEntries: defaultBreakEntries
                ))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Ensure the final data is sorted
        completeData.sort { $0.date < $1.date }
        return completeData
    }
    
    // Helper method to get all unique break types from data
    private func getAllBreakTypes(from data: [ExerciseChartModel]) -> [String] {
        // Extract all unique break types
        var breakTypes = Set<String>()
        for model in data {
            for entry in model.breakEntries {
                breakTypes.insert(entry.breakType)
            }
        }
        
        // If no data exists yet, add default break types
        if breakTypes.isEmpty {
            breakTypes = ["Long Break", "Medium Break", "Quick Break", "Short Break"]
        }
        
        return Array(breakTypes).sorted()
    }
}

#Preview {
    WaterBarChartView()
}


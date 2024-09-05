//
//  HealthManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 25/8/24.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager: ObservableObject {
    var healthStore: HKHealthStore?
    @Published var todayStepCount: Int = 0

    init() {
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]

        Task {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                do {
                    try await healthStore!.requestAuthorization(toShare: [], read: healthTypes)
                    fetchTodaySteps() // Fetch steps after getting authorization
                } catch {
                    print("Error fetching health data")
                }
            } else {
                print("Your device does not support health services")
            }
        }
    }

    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { [weak self] _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching today's step data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            DispatchQueue.main.async {
                self?.todayStepCount = Int(stepCount)
            }
        }
        healthStore!.execute(query)
    }
}

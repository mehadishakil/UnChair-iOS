//
//  HealthManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 25/8/24.
//

import Foundation
import HealthKit

extension Date{
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager: ObservableObject {
    var healthStore : HKHealthStore?
    
    init(){
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]
        
        Task{
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                do{
                    try await healthStore!.requestAuthorization(toShare: [], read: healthTypes)
                }catch{
                    print("Erroring fetching health data")
                }
            } else{
                print("your device does not support healh services")
            }
        }
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching todays step data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            print(stepCount)
        }
        healthStore!.execute(query)
    }
}

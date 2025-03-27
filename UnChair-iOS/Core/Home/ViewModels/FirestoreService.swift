//
//  FirestoreService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    // Fetch existing data for the user
    func fetchUserData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userId = userId else {
            print("No authenticated user available.")
            completion(.failure(NSError(domain: "FirestoreService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }

        db.collection("users").document(userId).collection("health_data").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([:]))
                return
            }
            let data = documents.reduce(into: [String: Any]()) { result, document in
                result[document.documentID] = document.data()
            }
            completion(.success(data))
        }
    }

    // Check if a document exists for the current date
    func documentExists(for date: String, completion: @escaping (Bool) -> Void) {
        guard let userId = userId else {
            print("No authenticated user available.")
            completion(false)
            return
        }

        db.collection("users").document(userId).collection("health_data").document(date).getDocument { snapshot, _ in
            completion(snapshot?.exists ?? false)
        }
    }

    // Create a new document for the current date
    func createDocument(for date: String, initialData: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let userId = userId else {
            print("No authenticated user available.")
            completion(NSError(domain: "FirestoreService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        db.collection("users").document(userId).collection("health_data").document(date).setData(initialData) { error in
            completion(error)
        }
    }

    // Sync data for the current date
    func syncData(for date: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let userId = userId else {
            print("No authenticated user available.")
            completion(NSError(domain: "FirestoreService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        db.collection("users").document(userId).collection("health_data").document(date).setData(updatedData, merge: true) { error in
            completion(error)
        }
    }
    
    
    func fetchWaterData(completion: @escaping ([WaterChartModel]) -> Void) {
        guard let userId = userId else {
            print("No authenticated user available.")
            completion([])
            return
        }
        
        db.collection("users").document(userId).collection("health_data").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching water data: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var waterData: [WaterChartModel] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd"
            
            for document in documents {
                let data = document.data()
                // Remove the prefix "daily_log_" from the document id.
                let dateString = document.documentID.replacingOccurrences(of: "daily_log_", with: "")
                if let waterIntake = data["waterIntake"] as? Double,
                   let date = formatter.date(from: dateString) {
                    let model = WaterChartModel(date: date, consumption: waterIntake)
                    waterData.append(model)
                }
            }
            
            // Sort by date in ascending order.
            waterData.sort { $0.date < $1.date }
            
            // Fill missing dates for the selected period.
            // You can adjust the period parameter ("Week", "Month", or "Year") as needed.
            let filledData = self.fillMissingDates(for: waterData, period: "Week")
            completion(filledData)
        }
    }

    /// This helper function takes the fetched data and fills in missing dates with default consumption (0).
    private func fillMissingDates(for data: [WaterChartModel], period: String) -> [WaterChartModel] {
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


protocol ChartDataModel: AnyObject {
    var date: Date { get }
    static func createDefault(for date: Date) -> Self
}

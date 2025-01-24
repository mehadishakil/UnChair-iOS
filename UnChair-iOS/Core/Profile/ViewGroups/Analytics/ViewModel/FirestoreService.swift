//
//  FirestoreService.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 24/1/25.
//

import Foundation
import FirebaseFirestore


class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private let userId = "user123" // Replace with your user's unique ID.

    // Fetch existing data for the user
    func fetchUserData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(userId).collection("dailyData").getDocuments { snapshot, error in
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
        db.collection("users").document(userId).collection("dailyData").document(date).getDocument { snapshot, _ in
            completion(snapshot?.exists ?? false)
        }
    }

    // Create a new document for the current date
    func createDocument(for date: String, initialData: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("dailyData").document(date).setData(initialData) { error in
            completion(error)
        }
    }

    // Sync data for the current date
    func syncData(for date: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("dailyData").document(date).setData(updatedData, merge: true) { error in
            completion(error)
        }
    }
    
    func fillMissingDates(completion: @escaping (Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Fetch all dates from Firestore
        db.collection("users").document(userId).collection("dailyData").getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(nil)
                return
            }

            let existingDates = Set(documents.map { $0.documentID })

            // Generate dates from the last known date to today
            var currentDate = Date()
            while !existingDates.contains(formatter.string(from: currentDate)) {
                let dateStr = formatter.string(from: currentDate)
                self.createDocument(for: dateStr, initialData: ["steps": 0, "waterConsumption": 0]) { error in
                    if error != nil {
                        completion(error)
                        return
                    }
                }
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            }
            completion(nil)
        }
    }

}

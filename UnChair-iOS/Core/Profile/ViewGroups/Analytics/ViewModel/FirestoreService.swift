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
        guard let userId = userId else {
            print("No authenticated user available.")
            completion(false)
            return
        }

        db.collection("users").document(userId).collection("dailyData").document(date).getDocument { snapshot, _ in
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

        db.collection("users").document(userId).collection("dailyData").document(date).setData(initialData) { error in
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

        db.collection("users").document(userId).collection("dailyData").document(date).setData(updatedData, merge: true) { error in
            completion(error)
        }
    }
}

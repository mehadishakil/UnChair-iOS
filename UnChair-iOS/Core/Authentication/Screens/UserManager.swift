//
//  UserManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 10/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserManager {
    static let shared = UserManager()
    
    private let db = Firestore.firestore()
    var userData: [String: Any] = [:]
    
    private init() {}
    
    func fetchUserData(uid: String) async throws -> [String: Any]? {
            let userRef = db.collection("users").document(uid)
            let snapshot = try await userRef.getDocument()
            
            if snapshot.exists, let data = snapshot.data() {
                return data
            } else {
                return nil
            }
        }
}

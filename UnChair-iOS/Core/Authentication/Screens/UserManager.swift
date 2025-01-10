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
    
    func loadUserData(user: User) async throws {
        let userRef = db.collection("users").document(user.uid)
        let snapshot = try await userRef.getDocument()
        
        if snapshot.exists, let data = snapshot.data() {
            self.userData = data
        }
    }
}

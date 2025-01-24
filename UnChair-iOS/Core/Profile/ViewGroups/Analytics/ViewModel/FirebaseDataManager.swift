//
//  FirebaseDataManager.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 20/1/25.
//

//import FirebaseFirestore
//
//
//
//@MainActor
//@Observable
//class FirebaseDataManager: ObservableObject {
//    
//    let db = Firestore.firestore()
//    let settings = FirestoreSettings()
//    
//    init () {
//        settings.isPersistenceEnabled = true
//        db.settings = settings
//    }
//
//
//    func getCurrentDateString() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: Date())
//    }
//    
//    func getUserData(userID: String) -> UserData? {
//        let currentdate = getCurrentDateString()
//        var data : UserData?
//        db.collection("users").document(userID).collection("ExerciseChartModel").document(currentdate)
//            .getDocument { document, error in
//                if let document = document, document.exists {
//                    data = document.data()
//                    // Use the data in your app
//                } else {
//                    print("Document does not exist")
//                }
//            }
//        return data
//    }
//
//    func saveDataForToday(userID: String, steps: Int, waterConsumption: Int) {
//        let db = Firestore.firestore()
//        let currentDate = getCurrentDateString() // Get the current date in "yyyy-MM-dd" format
//
//        // Use the currentDate as the document ID
//        db.collection("users").document(userID).collection("dailyData").document(currentDate).setData([
//            "steps": steps,
//            "waterConsumption": waterConsumption
//        ], merge: true) { error in
//            if let error = error {
//                print("Error writing document: \(error)")
//            } else {
//                print("Document successfully written!")
//            }
//        }
//    }
//
//
//}





//struct ExerciseData: Codable {
//    var userId: String
//    var date: Date
//    var exerciseType: String
//    var duration: Int // Duration in minutes
//}
//
//struct SleepsData: Codable {
//    var userId: String
//    var date: Date
//    var sleepHours: Double
//}
//
//struct StepsData: Codable {
//    var userId: String
//    var date: Date
//    var steps: Int
//}
//
//struct WaterConsumptionData: Codable {
//    var userId: String
//    var date: Date
//    var waterLiters: Double
//}

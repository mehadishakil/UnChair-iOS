import Foundation
import SwiftData

@Model
class UserModel {
    var uid: String
    var name: String
    var email: String
    var provider: String
    
    init(uid: String, name: String, email: String, provider: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.provider = provider
    }
} 
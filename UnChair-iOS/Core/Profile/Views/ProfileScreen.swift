//
//  ProfileScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case English = "English"
    case Bangla = "Bangla"
    case Arabic = "Arabic"
    var id: String { self.rawValue}
}

enum Notification : String, CaseIterable, Identifiable {
    case Allow = "Allow"
    case Mute = "Mute"
    var id : String {self.rawValue}
}

struct ProfileScreen: View {

    @State private var language : Language = .English
    @State private var notification : Notification = .Allow
    
    var body: some View {
        Form{
            Section(header: Text("Essential")){
                Picker("Language", selection: $language){
                    Text("English").tag(Language.English)
                    Text("Bangla").tag(Language.Bangla)
                    Text("Arabic").tag(Language.Arabic)
                }
                Picker("Notification", selection: $notification){
                    Text("Allow").tag(Notification.Allow)
                    Text("Mute").tag(Notification.Mute)
                }
            }
        }
    }
}

#Preview {
    ProfileScreen()
}

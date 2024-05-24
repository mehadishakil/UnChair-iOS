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


struct ProfileScreen: View {

    @State private var language : Language = .English
    @State private var isNotificationEnabled = true
    @State private var isDarkOn = true
    
    var body: some View {
        Form{
            Section(header: Text("Essential")){
                HStack{
                    Text("Help & Feedback")
                    Spacer()
                    Image("chevron.right")
                }
            }
            
            Section(header: Text("Personalization")){
                HStack{
                    Toggle(isOn: $isNotificationEnabled){
                        Text("Notification")
                    }
                }
                Toggle(isOn: $isDarkOn){
                    Text("Dark Mode")
                }
                Picker("Language", selection: $language){
                    Text("English").tag(Language.English)
                    Text("Bangla").tag(Language.Bangla)
                    Text("Arabic").tag(Language.Arabic)
                }
            }
        }
    }
}

#Preview {
    ProfileScreen()
}

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
            
            
            Section{
                HStack{
                    Image(.mehadiHasan)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .padding(1)
                    
                    VStack(alignment: .leading){
                        Text("Mehadi Hasan")
                            .font(.system(.headline))
                        Text("mehadishakil469@gmail.com")
                            .font(.system(.caption))
                            .foregroundColor(Color.black)
                    }.padding(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            
            Section(header: Text("Personalization")){
                HStack{
                    Image(systemName: "bell")
                    Toggle(isOn: $isNotificationEnabled){
                        Text("Notification")
                    }
                }
                HStack{
                    Image(systemName: "moon")
                    Toggle(isOn: $isDarkOn){
                        Text("Dark Mode")
                    }
                }
                HStack{
                    Image(systemName: "globe")
                    Picker("Language", selection: $language){
                        Text("English").tag(Language.English)
                        Text("Bangla").tag(Language.Bangla)
                        Text("Arabic").tag(Language.Arabic)
                    }
                }
            }
            
            Section(header: Text("Accessibility & Advanced")){
                HStack{
                    Image(systemName: "face.smiling")
                    Text("Help & Feedback")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "checkmark.shield")
                    Text("Permissions")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "questionmark.circle")
                    Text("About")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "doc.plaintext")
                    Text("Terms & Service")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "heart")
                    Text("Support Us")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "info.bubble")
                    Text("FAQ")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                HStack{
                    Image(systemName: "person.fill.questionmark")
                    Text("Help")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            
        }
    }
}

#Preview {
    ProfileScreen()
}

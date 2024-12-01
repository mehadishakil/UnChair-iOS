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
    
    @Binding var selectedDuration: TimeDuration
    @State private var language : Language = .English
    @State private var isNotificationEnabled = true
    @State private var isDarkOn = true
    @State private var startTime = Calendar
        .current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var endTime = Calendar
        .current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var changeTheme: Bool = false
    // @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    // @State private var appearanceMode : AppearanceMode = .light
    // @AppStorage("user_theme") private var userTheme: AppearanceMode = .system
    // @State private var colorScheme : ColorScheme? = nil
    @Environment(\.colorScheme) private var scheme
    @State var show = false
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    
    var body: some View {
        NavigationView{
            Form{
                // user profile
                Section{
                    NavigationLink(destination: EditProfile()) {
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
                        }
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
                        Button(action: {
                            show.toggle()
                        }) {
                            HStack {
                                Image(systemName: "circle.lefthalf.filled")
                                    .foregroundColor(.primary)
                                Text("Appearance")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $show) {
                            DLMode(show: $show, scheme: scheme)
                                .presentationDetents([.height(280)])
                                .presentationBackground(.clear)
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
                    
                    ActiveHour()
                    
                    
                    BreakTime(selectedDuration: $selectedDuration)
                    
                }
                
                Section(header: Text("Accessibility & Advanced")) {
                    NavigationLink(destination: RestorePurchaseView()) {
                        HStack {
                            Image(systemName: "creditcard")
                            Text("Restore Purchase")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: TermsServiceView()) {
                        HStack {
                            Image(systemName: "doc.plaintext")
                            Text("Terms of Use")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: ContactUsView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("Privacy Policy")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: PermissionsView()) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("Permissions")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: ContactUsView()) {
                        HStack {
                            Image(systemName: "phone")
                            Text("Contact Us")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: FeedbackView()) {
                        HStack {
                            Image(systemName: "face.smiling")
                            Text("Feedback")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("About")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: FAQView()) {
                        HStack {
                            Image(systemName: "info.bubble")
                            Text("FAQ")
                            Spacer()
                        }
                    }
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Help")
                            Spacer()
                        }
                    }
                    
                }
                
                Button{
                    
                } label: {
                    Text("Sign Out")
                        .foregroundColor(.primary)
                }
                
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
    }
}



#Preview {
    ProfileScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}



// some dummy views
// Dummy views for navigation destinations
struct UserProfileView: View {
    var body: some View {
        Text("User Profile")
            .navigationTitle("User Profile")
    }
}

struct RestorePurchaseView: View {
    var body: some View {
        Text("Restore Purchase")
            .navigationTitle("Restore Purchase")
    }
}



struct PermissionsView: View {
    var body: some View {
        Text("Permissions")
            .navigationTitle("Permissions")
    }
}

struct AboutView: View {
    var body: some View {
        Text("About")
            .navigationTitle("About")
    }
}

struct TermsServiceView: View {
    var body: some View {
        Text("Terms & Service")
            .navigationTitle("Terms & Service")
    }
}
struct FAQView: View {
    var body: some View {
        Text("FAQ")
            .navigationTitle("FAQ")
    }
}

struct HelpView: View {
    var body: some View {
        Text("Help")
            .navigationTitle("Help")
    }
}


//
//  ProfileScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

enum Language: String, CaseIterable, Identifiable {
    case English = "English"
    case Bangla = "Bangla"
    case Arabic = "Arabic"
    var id: String { self.rawValue }
}

struct SettingsScreen: View {
    
    @Binding var selectedDuration: TimeDuration
    @State private var language : Language = .English
    @State private var isNotificationEnabled = false // This is now our app-level toggle
    @State private var showPermissionAlert = false
    @State private var isDarkOn = true
    @State private var startTime = Calendar
        .current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var endTime = Calendar
        .current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var changeTheme: Bool = false
    @Environment(\.colorScheme) private var scheme
    @State var show = false
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @EnvironmentObject var authController: AuthController
    @State private var full_name: String = ""
    @State private var email: String = ""
    @State private var signoutAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    var db = Firestore.firestore()
    
    
    var body: some View {
        NavigationView {
            Form {
                // User profile section
                Section {
                    NavigationLink(destination: EditProfile()) {
                        HStack {
                            if let user = Auth.auth().currentUser, let profileImageURL = user.photoURL {
                                
                                AsyncImage(url: URL(string: profileImageURL.absoluteString)) { phase in
                                    switch phase {
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(Circle())
                                            .padding(1)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(Circle())
                                            .padding(1)
                                    default:
                                        ProgressView()
                                    }
                                }
                                
                                
                            } else {
                                VStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle())
                                        .padding(1)
                                }}
                            
                            VStack(alignment: .leading) {
                                Text(full_name)
                                    .font(.system(.headline))
                                Text(email)
                                    .font(.system(.caption))
                                
                            }.padding(1)
                            
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Personalization")) {
                    HStack {
                        Image(systemName: "bell")
                        Toggle(isOn: $isNotificationEnabled) {
                            Text("Break Reminders")
                        }
                        .onChange(of: isNotificationEnabled) { newValue in
                            handleNotificationToggle(newValue)
                        }
                    }
                    
                    HStack {
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
                    
                    HStack {
                        Image(systemName: "globe")
                        Picker("Language", selection: $language) {
                            Text("English").tag(Language.English)
                            Text("Bangla").tag(Language.Bangla)
                            Text("Arabic").tag(Language.Arabic)
                        }
                    }
                    
                    ActiveHour()
                    
                    BreakTime()
                }
                .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
                    Button("Cancel", role: .cancel) {
                        isNotificationEnabled = false
                    }
                    Button("Open Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                } message: {
                    Text("To receive break reminders, please enable notifications in iOS Settings, then return here to turn on break reminders.")
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
                
                Button {
                    signoutAlert.toggle()
                } label: {
                    Text("Sign Out")
                        .foregroundColor(.primary)
                }
                .alert("Sign Out", isPresented: $signoutAlert) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    Button {
                        do {
                            try authController.signOut()
                        } catch {
                            print(error.localizedDescription)
                        }
                    } label: {
                        Text("Yes")
                    }
                } message: {
                    Text("Are you sure?")
                }
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
        .onAppear {
            fetchUserData()
            loadNotificationSettings()
        }
    }
    
    // MARK: - Updated notification handling methods
    
    private func handleNotificationToggle(_ newValue: Bool) {
        if newValue {
            // User wants to enable notifications
            checkAndRequestNotificationPermission()
        } else {
            // User wants to disable notifications
            NotificationManager.shared.isAppNotificationEnabled = false
        }
    }
    
    private func checkAndRequestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // First time: request permission
                    NotificationManager.shared.requestAuthorization { granted in
                        if granted {
                            // Permission granted, enable app-level toggle
                            NotificationManager.shared.isAppNotificationEnabled = true
                            isNotificationEnabled = true
                        } else {
                            // Permission denied, keep toggle off
                            isNotificationEnabled = false
                        }
                    }

                case .denied:
                    // Already denied: show alert to guide user to Settings
                    showPermissionAlert = true

                case .authorized, .provisional, .ephemeral:
                    // Already allowed: enable app-level toggle
                    NotificationManager.shared.isAppNotificationEnabled = true
                    isNotificationEnabled = true

                @unknown default:
                    isNotificationEnabled = false
                }
            }
        }
    }
    
    private func loadNotificationSettings() {
        // Load the app-level notification setting
        isNotificationEnabled = NotificationManager.shared.isAppNotificationEnabled
        
        // Also check if system permission has been revoked
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                // If system permission is denied but app toggle is on, turn off app toggle
                if settings.authorizationStatus == .denied && isNotificationEnabled {
                    isNotificationEnabled = false
                    NotificationManager.shared.isAppNotificationEnabled = false
                }
            }
        }
    }
    
    private func fetchUserData() {
        if let currentUser = Auth.auth().currentUser {
            Task {
                do {
                    if let userData = try await UserManager.shared.fetchUserData(uid: currentUser.uid) {
                        full_name = userData["name"] as? String ?? ""
                        email = userData["email"] as? String ?? ""
                    }
                } catch {
                    print("Error loading user data: \(error)")
                }
            }
        }
    }
}

#Preview {
    SettingsScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
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


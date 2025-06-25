//
//  AboutView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 29/5/25.
//


import SwiftUI

struct AboutView: View {
    let url = URL(string: "https://un-chair-landing-page.vercel.app/")!
    @State private var isLoading = true

    var body: some View {
        Form {
            Section(header: Text("App Info")) {
                HStack {
                    Text("App Name")
                    Spacer()
                    Text("UnChair")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Israil Ahmed")
                        .foregroundColor(.secondary)
                }
            }

            Section() {
                NavigationLink("Visit our website") {
                    ZStack {
                        WebView(url: url, isLoading: $isLoading)
                            .edgesIgnoringSafeArea(.bottom)

                        if isLoading {
                            ProgressView("Loading")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
                    .toolbar(.hidden, for: .tabBar)
                }
            }

            Section {
                Text("UnChair is a wellness app designed to improve your worklife with healthy break reminders, meditation sessions, and activity tracking. Thank you for using our app!")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}

//
//  TermsOfUseView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 29/5/25.
//


import SwiftUI

struct TermsOfUseView: View {
    @State private var isLoading = true
    private let url = URL(string: "https://un-chair-landing-page.vercel.app/terms-of-use")!

    var body: some View {
        ZStack {
            WebView(url: url, isLoading: $isLoading)
                .edgesIgnoringSafeArea(.bottom)

            if isLoading {
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
}

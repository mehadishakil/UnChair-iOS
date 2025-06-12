//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeScreen: View {
    @Binding var selectedDuration: TimeDuration
    @State private var notificationPermissionGranted = false
    @State private var showDetail = false
    @Namespace private var namespace
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    @State private var selectedBreak: Break? = nil
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack {
                            Color.backgroundtheme.opacity(0.7)
                                .ignoresSafeArea()
                            VStack(spacing: 0) {
                                HeaderView()
                                HCalendarView()
                                    .padding(.vertical)
                                GlassCard{
                                    SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted,
                                                  selectedDuration: $selectedDuration) {
                                        withAnimation {
                                            proxy.scrollTo("breakSection", anchor: .top)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                                
                                
                                DailyTracking()
                                
                                
                                BreakSectionView(breakList: breakList)
                                    .id("breakSection")
                                
                                
                                CalmCorner()
                            }
                            .onAppear {
                                requestNotificationPermission()
                            }
//                            .refreshable {
//                                healthViewModel.refreshData()
//                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
    }
    
    
    struct BreakSectionView: View {
        // MARK: – PUBLIC API
        let breakList: [Break]
        
        // MARK: – INTERNAL STATE
        @State private var selectedIndex: Int = 0
        
        // MARK: – LAYOUT CONSTANTS
        private let cardInset: CGFloat = 50
        private var sideInset: CGFloat { cardInset / 2 }
        private let cardHeight: CGFloat = 170
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Breaks")
                    .font(.title2.weight(.semibold))
                    .padding(.horizontal, 20)
                
                TabView(selection: $selectedIndex) {
                    ForEach(breakList.indices, id: \.self) { idx in
                        NavigationLink(destination: DetailsBreakView(breakItem: breakList[idx])) {
                            ZStack {
                                GeometryReader { geo in
                                    // OPTIONAL PARALLAX EFFECT:
                                    let midX      = geo.frame(in: .global).midX
                                    let screenMid = UIScreen.main.bounds.width / 2
                                    let dist      = midX - screenMid
                                    let parallax  = -dist * 0.2
                                    
                                    Image(breakList[idx].image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .offset(x: parallax)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .cornerRadius(20)
                                
                                OverlayView(item: breakList[idx])
                            }
                            .padding(.horizontal)
                            .frame(height: cardHeight)
                            .tag(idx)
                        }
                    }
                }
                .frame(height: cardHeight)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // MARK: - Active Item Indicator
                HStack(spacing: 8) {
                    Spacer()
                    
                    ForEach(breakList.indices, id: \.self) { index in
                        Circle()
                            .fill(index == selectedIndex ? .primary : .secondary)
                            .frame(width: 6, height: 6)
                            .scaleEffect(index == selectedIndex ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        
        
        // MARK: – YOUR OVERLAY VIEW (unchanged)
        @ViewBuilder
        private func OverlayView(item: Break) -> some View {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(
                        // Gradient mask to create fade effect
                        LinearGradient(
                            colors: [
                                .black,
                                .black.opacity(0.8),
                                .clear,
                                .clear,
                                .clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                
                // Additional tint for better contrast
                LinearGradient(
                    colors: [
                        .black.opacity(0.5),
                        .black.opacity(0.3),
                        .clear,
                        .clear,
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title)
                        .bold()
                    Text(item.overview)
                        .font(.footnote)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = success
                if !success, let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        switch minutes {
        case 0: return "\(seconds) seconds"
        case 1: return "1 minute"
        default: return "\(minutes) minutes"
        }
    }
    
    
}



#Preview {
    HomeScreen(selectedDuration: .constant(TimeDuration(hours: 0, minutes: 45)))
}

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
                                
                                
                                breakSectionView
                                    .id("breakSection")
                                
                                CalmCorner()
                            }
                            .onAppear {
                                requestNotificationPermission()
                                healthViewModel.refreshData()
                            }
                            .refreshable {
                                healthViewModel.refreshData()
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(userTheme.colorScheme)
        .fullScreenCover(isPresented: $showDetail) {
            BreakDetailsView(namespace: namespace, show: $showDetail, breakItem: selectedBreak == nil ? breakList[0] : selectedBreak!)
                .ignoresSafeArea()
        }
    }
    
    var breakSectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Breaks")
                .font(.title2.weight(.semibold))
                .padding(.horizontal, 20)

            GeometryReader { outer in
                let containerSize = outer.size
                let cardInset: CGFloat = 50
                let sideInset = cardInset / 2

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(breakList) { item in
                            GeometryReader { geo in
                                let cardFrame      = geo.frame(in: .global)
                                let cardMidX       = cardFrame.midX
                                let screenMidX     = UIScreen.main.bounds.width / 2
                                let strength: CGFloat = 0.95
                                let distance       = cardMidX - screenMidX
                                let parallaxOffset = -distance * strength

                                Image(item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: cardFrame.width, height: cardFrame.height)
                                    .offset(x: parallaxOffset)
                                    .cornerRadius(20)
                                    .overlay {
                                        OverlayView(item: item)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .onTapGesture {
                                        selectedBreak = item
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showDetail = true
                                        }
                                    }
                            }
                            .frame(
                                width: containerSize.width - cardInset,
                                height: containerSize.height
                            )
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                view.scaleEffect(phase.isIdentity ? 1 : 0.98)
                            }
                        }
                    }
                    .padding(.trailing, sideInset)
                    .padding(.leading)
                    .frame(height: containerSize.height)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
            }
            .frame(height: 170)
            .padding(.top)
        }
    }
    
    @ViewBuilder
    func OverlayView(item: Break) -> some View {
        ZStack(alignment: .bottomLeading, content: {
            LinearGradient(colors: [.clear, .clear, .clear, .black.opacity(0.1), .black.opacity(0.5), .black], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 2, content: {
                Text("\(item.title)")
                    .font(.title)
                    .bold()
                
                Text("\(item.overview)")
                    .font(.footnote)
            })
            .foregroundColor(.white)
            .padding()
        })
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

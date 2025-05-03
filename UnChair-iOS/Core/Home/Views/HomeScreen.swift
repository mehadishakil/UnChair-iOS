//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct HomeScreen: View {
    @Binding var selectedDuration: TimeDuration
    @State private var notificationPermissionGranted = false
    @State private var showDetail = false
    @Namespace private var namespace
    @EnvironmentObject var healthViewModel: HealthDataViewModel
    @State private var selectedBreak: Break? = nil
    
    
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
                                    .padding(.bottom)
                                GlassCard{
                                    SedentaryTime(notificationPermissionGranted: $notificationPermissionGranted,
                                                  selectedDuration: $selectedDuration) {
                                        withAnimation {
                                            proxy.scrollTo("breakSection", anchor: .top)
                                        }
                                    }
                                }
                                .padding()
                                
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
        .fullScreenCover(isPresented: $showDetail) {
            BreakDetailsView(namespace: namespace, show: $showDetail, breakItem: selectedBreak == nil ? breakList[0] : selectedBreak!)
                .ignoresSafeArea()
        }
    }
    
    var breakSectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
//            Text("Take a break")
//                .font(.footnote.weight(.semibold))
//                .foregroundColor(.secondary)
//                .padding(.horizontal, 20)
            Text("Take a break")
              .font(.title2).fontWeight(.semibold)
              .padding(.horizontal, 20)
            
            GeometryReader { outer in
                let containerSize = outer.size
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(breakList) { item in
                            GeometryReader { geo in
                                let cardSize = geo.size
                                let minX = min(geo.frame(in: .scrollView).minX * 1.4, geo.size.width * 1.4)
                                
                                Image(item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .offset(x: -minX)
                                    .frame(width: cardSize.width * 2.5)
                                    .frame(width: cardSize.width, height: cardSize.height)
                                    .overlay(content: {
                                        OverlayView(item: item)
                                    })
                                    .clipShape(.rect(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 5, y: 10)
                                    .contentShape(Rectangle()) // Ensure the entire area is tappable
                                    .onTapGesture {
                                        selectedBreak = item
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showDetail = true
                                        }
                                    }
                            }
                            .frame(
                                width: containerSize.width - 30,
                                height: containerSize.height - 50
                            )
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                view.scaleEffect(phase.isIdentity ? 1 : 0.94)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollTargetLayout()
                    .frame(height: containerSize.height)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
            }
            .frame(height: 230)
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

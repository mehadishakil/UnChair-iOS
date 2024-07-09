//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    HeaderView()
                    HCalendarView().padding(.bottom)
                    SedentaryTime().padding()
                    DailyTracking()
                    Spacer()
                    BreakSectionView()
                        .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}

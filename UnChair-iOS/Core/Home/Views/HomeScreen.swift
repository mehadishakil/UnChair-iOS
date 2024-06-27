//
//  HomeScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack{
            HCalendarView().padding(.bottom)
            SedentaryTime()
        }
    }
}

#Preview {
    HomeScreen()
}

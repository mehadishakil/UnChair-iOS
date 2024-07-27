//
//  AnalyticScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct AnalyticScreen: View {
    var body: some View {
        VStack{
            Home()
            
            Spacer()
            
            SleepChartView()
                .padding(.horizontal)
        }
    }
}

#Preview {
    AnalyticScreen()
}

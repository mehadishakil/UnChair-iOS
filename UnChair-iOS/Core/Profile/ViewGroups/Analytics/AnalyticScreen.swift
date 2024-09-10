//
//  AnalyticScreen.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 21/5/24.
//

import SwiftUI

struct AnalyticScreen: View {
    var body: some View {
        ScrollView{
            VStack{
                BreakMultiLineChartView()
                    .padding()
                
                Spacer()
                
                StepsBarChartView()
                    .padding()
                
                Spacer()
                
                WaterLineChartView()
                    .padding()
                
                SleepBarChartView()
                    .padding()
            }
        }
    }
}

#Preview {
    AnalyticScreen()
}

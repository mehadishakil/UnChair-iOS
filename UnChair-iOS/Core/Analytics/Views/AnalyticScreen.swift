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
                
                WaterLineChartView(isBar: .constant(true))
                    .padding()
                
                Spacer()
                
                SleepBarChartView()
                    .padding()
                
                WaterLineChartView(isBar: .constant(false))
                    .padding()
                
            }
        }
    }
}

#Preview {
    AnalyticScreen()
}

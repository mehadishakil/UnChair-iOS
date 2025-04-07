//
//  AnalyticScreen.swift
//  ModuleDraft
//
//  Created by Mehadi Hasan on 10/9/24.
//

import SwiftUI

struct AnalyticScreen: View {
    var body: some View {
        ScrollView{
            VStack{
                WaterBarChartView()
                    .padding()
                
                StepsLineChartView()
                    .padding()
                
                SleepCapsuleChartView()
                    .padding()
//                
//                ExerciseBarChartView()
//                    .padding()
                
//                Sample()
//                    .padding()
                
                LollipopMeditationChart()
                    .padding()
            }
        }
    }
}

#Preview {
    AnalyticScreen()
}

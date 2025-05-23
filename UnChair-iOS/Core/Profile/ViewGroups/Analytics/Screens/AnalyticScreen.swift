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
                    .padding(.horizontal)
                
                StepsLineChartView()
                    .padding()
                
                SleepCapsuleChartView()
                    .padding(.horizontal)
                
                ExerciseMultiLineChartView()
                    .padding()
                
                MeditationLollipopChartView()
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}

#Preview {
    AnalyticScreen()
}

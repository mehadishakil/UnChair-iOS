//
//  SedentaryTime.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 5/6/24.
//

import SwiftUI

struct SedentaryTime: View {
    
    @State var startTime = Date.now
    @State var timeElapsed : Int = 0
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(){
            Spacer()
            
            Image(systemName: "hourglass.tophalf.filled")
                .resizable()
                .frame(width: 70, height: 100)
            
            Spacer()
            
            VStack(alignment : .center){
                Text("Sedentary Time")
                    .font(.headline)

                Text("\(formattedTime(timeElapsed))")
                    .font(.title3)
                    .onReceive(timer){ firedDate in
                        timeElapsed = Int(firedDate.timeIntervalSince(startTime))
                    }
                
                Button{
                    startTime = Date.now
                }label: {
                    Text("Reset")
                }.buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}




func formattedTime(_ totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let min = (totalSeconds % 3600) / 60
    let sec = totalSeconds % 60
    
    return String(format: "%02d:%02d:%02d", hours, min, sec)
}



#Preview {
    SedentaryTime()
}

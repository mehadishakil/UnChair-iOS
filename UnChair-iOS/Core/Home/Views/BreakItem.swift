//
//  BreakItem.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 23/4/25.
//


import SwiftUI

struct BreakItem: View {
    var namespace : Namespace.ID
    @Binding var show : Bool
    var breakItem : Break
    
    var body: some View {
        VStack{
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(breakItem.title)
                        .font(.largeTitle)
                        .matchedGeometryEffect(id: "title", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Approx \(formatDuration(seconds: breakItem.duration))".uppercased())
                        .font(.footnote.weight(.semibold))
                        .matchedGeometryEffect(id: "subtitle", in: namespace)
                    
                    Text(breakItem.overview)
                        .font(.footnote)
                        .matchedGeometryEffect(id: "text", in: namespace)
                }
                .padding(20)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .blur(radius: 80)
                        .matchedGeometryEffect(id: "blur", in: namespace)
                )
            }
            
            .foregroundStyle(.white)
            .background(
                Image("shortbreakimage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .matchedGeometryEffect(id: "background", in: namespace)
            )
            .mask {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .matchedGeometryEffect(id: "mask", in: namespace)
            }
            .frame(height: 200)
            .padding(20)

        }
    }
    
    func formatDuration(seconds: Int) -> String {
            let minutes = seconds / 60
            if minutes < 1 {
                return "\(seconds) seconds"
            } else if minutes == 1 {
                return "1 minute"
            } else {
                return "\(minutes) minutes"
            }
        }
}

struct BreakItem_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        BreakItem(namespace: namespace, show: .constant(true), breakItem: breakList[0])
    }
}

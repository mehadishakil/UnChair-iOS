//
//  BreakDetailsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 23/4/25.
//


import SwiftUI

struct BreakDetailsView: View {
    var namespace: Namespace.ID
    @Binding var show: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 300)
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
            .overlay(
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Short Break")
                        .font(.largeTitle)
                        .matchedGeometryEffect(id: "title", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Approx 2 mins".uppercased())
                        .font(.footnote.weight(.semibold))
                        .matchedGeometryEffect(id: "subtitle", in: namespace)
                    
                    Text("Build an iOS app for iOS 15 with custom layouts, animations and ...")
                        .font(.footnote)
                        .matchedGeometryEffect(id: "text", in: namespace)
                    
                    
//                    Divider()
//                    
//                    HStack{
//                        Image("mehadi_hasan")
//                            .resizable()
//                            .frame(width: 26, height: 26)
//                            .cornerRadius(10)
//                            .padding(8)
//                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
//                            .overlay(
//                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
//                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                                )
//                        
//                        Text("This is Mehadi Hasan")
//                            .font(.footnote)
//                        
//                    }
                }
                    .padding(20)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .matchedGeometryEffect(id: "blur", in: namespace)
                    )
                    .offset(y: 200)
                    .padding(20)
            )
        }
    }
}


struct BreakDetailsView_Previews : PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        BreakDetailsView(namespace: namespace, show: .constant(true))
    }
}
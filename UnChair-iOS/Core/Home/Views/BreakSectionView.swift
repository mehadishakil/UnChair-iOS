//
//  BreakSectionView 2.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 23/4/25.
//


import SwiftUI

//struct BreakSectionView: View {
//    
//    @State var hasScrolled = false
//    @Namespace var namespace
//    @Binding var show : Bool
//    
//    var body: some View {
//        
//            
//            ScrollView {
//                
//                if !show {
//                    BreakItem(namespace: namespace, show: $show, breakItem: breakList[0])
//                        .onTapGesture {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                                show.toggle()
//                            }
//                        }
//                }
//            }
//            .coordinateSpace(name: "scroll")
//            .safeAreaInset(edge: .top, content: {    Color.clear.frame(height: 70)
//            })
//            if show {
//                BreakDetailsView(namespace: namespace, show: $show)
//                    .onTapGesture {
//                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                            show.toggle()
//                        }
//                    }
//            }
//        }
//    
//    
//    
//}


//struct BreakSectionView: View {
//    var namespace: Namespace.ID
//    @Binding var show: Bool                              // now driven by parent
//
//    var body: some View {
//        ZStack {
//            Color("Background").ignoresSafeArea()
//
//            ScrollView {
//                if !show {
//                    BreakItem(namespace: namespace, show: $show, breakItem: breakList[0])
//                        .onTapGesture {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                                show.toggle()
//                            }
//                        }
//                }
//            }
//            .safeAreaInset(edge: .top) {
//                Color.clear.frame(height: 70)
//            }
//        }
//    }
//}


#Preview {
    // BreakSectionView(.constant(true))
}

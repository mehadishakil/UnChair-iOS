//
//  BreakDetailsView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 23/4/25.
//


import SwiftUI

//struct BreakDetailsView: View {
//    var namespace: Namespace.ID
//    @Binding var show: Bool
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                Spacer()
//            }
//            .frame(maxWidth: .infinity)
//            .frame(minHeight: 300)
//            .foregroundStyle(.white)
//            .background(
//                Image("shortbreakimage")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .matchedGeometryEffect(id: "background", in: namespace)
//            )
//            .mask {
//                RoundedRectangle(cornerRadius: 30, style: .continuous)
//                    .matchedGeometryEffect(id: "mask", in: namespace)
//            }
//            .overlay(
//                VStack(alignment: .leading, spacing: 12) {
//
//                    Text("Short Break")
//                        .font(.largeTitle)
//                        .matchedGeometryEffect(id: "title", in: namespace)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Text("Approx 2 mins".uppercased())
//                        .font(.footnote.weight(.semibold))
//                        .matchedGeometryEffect(id: "subtitle", in: namespace)
//
//                    Text("Build an iOS app for iOS 15 with custom layouts, animations and ...")
//                        .font(.footnote)
//                        .matchedGeometryEffect(id: "text", in: namespace)
//
//
////                    Divider()
////
////                    HStack{
////                        Image("mehadi_hasan")
////                            .resizable()
////                            .frame(width: 26, height: 26)
////                            .cornerRadius(10)
////                            .padding(8)
////                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
////                            .overlay(
////                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
////                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
////                                )
////
////                        Text("This is Mehadi Hasan")
////                            .font(.footnote)
////
////                    }
//                }
//                    .padding(20)
//                    .background(
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
//                            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                            .matchedGeometryEffect(id: "blur", in: namespace)
//                    )
//                    .offset(y: 200)
//                    .padding(20)
//            )
//        }
//    }
//}
//
//
//struct BreakDetailsView_Previews : PreviewProvider {
//    @Namespace static var namespace
//    static var previews: some View {
//        BreakDetailsView(namespace: namespace, show: .constant(true))
//    }
//}







//
//struct BreakDetailsView: View {
//    var namespace: Namespace.ID
//    @Binding var show: Bool
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                Spacer()
//            }
//            .frame(maxWidth: .infinity)
//            .frame(minHeight: 300)
//            .foregroundStyle(.white)
//            .background(
//                Image("shortbreakimage")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .matchedGeometryEffect(id: "background", in: namespace)
//            )
//            .mask(
//                RoundedRectangle(cornerRadius: 30, style: .continuous)
//                    .matchedGeometryEffect(id: "mask", in: namespace)
//            )
//            .overlay(
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Short Break")
//                        .font(.largeTitle)
//                        .matchedGeometryEffect(id: "title", in: namespace)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Text("APPROX 2 MINS")
//                        .font(.footnote.weight(.semibold))
//                        .matchedGeometryEffect(id: "subtitle", in: namespace)
//
//                    Text("Build an iOS app for iOS 15 with custom layouts, animations and ...")
//                        .font(.footnote)
//                        .matchedGeometryEffect(id: "text", in: namespace)
//                }
//                .padding(20)
//                .background(
//                    Rectangle()
//                        .fill(.ultraThinMaterial)
//                        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                        .matchedGeometryEffect(id: "blur", in: namespace)
//                )
//                .offset(y: 200)
//                .padding(20)
//            )
//        }
//    }
//}




struct BreakDetailsView: View {
    var namespace: Namespace.ID
    @Binding var show: Bool
    var breakItem: Break
    @State private var navigateToExercise = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    
                    contentSection
                }
            }
            .ignoresSafeArea()
            
            closeButton
        }
        .background(Color(Color.primary).opacity(0.25))
        .fullScreenCover(isPresented: $navigateToExercise) {
            StartExerciseView(breakItem: breakItem)
        }
    }
    
    var headerSection: some View {
        VStack {
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .foregroundStyle(.white)
        .background(
            Image(breakItem.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: "background", in: namespace)
        )
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        }
    }
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(breakItem.title)
                .font(.largeTitle)
                .matchedGeometryEffect(id: "title", in: namespace)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Approx \(breakItem.duration / 60) mins".uppercased())
                .font(.footnote.weight(.semibold))
                .matchedGeometryEffect(id: "subtitle", in: namespace)
            
            Text(breakItem.description)
                .font(.footnote)
                .matchedGeometryEffect(id: "text", in: namespace)
            
            Divider()
            
            Text("Exercises")
                .font(.title2.bold())
                .padding(.top)
            
            ForEach(breakItem.exercises) { exercise in
                HStack {
                    Image(exercise.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(10)
                        .padding(8)
                    // apply a material blur behind each image if desired
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.description)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(exercise.duration)s")
                        .font(.footnote.bold())
                }
            }
            
            Button {
                navigateToExercise = true
            } label: {
                Text("Next")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.whiteblack)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.primary)
                    .cornerRadius(10)
            }
            .padding(.vertical, 20)
        }
        .padding(20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .matchedGeometryEffect(id: "blur", in: namespace)
        )
        .padding(4)
    }
    
    var closeButton: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                show.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.bold))
                .foregroundColor(.secondary)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(50)
        .ignoresSafeArea()
    }
}

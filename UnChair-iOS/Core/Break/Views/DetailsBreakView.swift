//
//  DetailsBreakView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI

struct DetailsBreakView: View {
    let breakItem: Break
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                ZStack(alignment: .bottomLeading){
                    Image(breakItem.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(1), Color.black.opacity(0)]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 150),
                            alignment: .bottom
                        )
                        .edgesIgnoringSafeArea(.all)

                    Text(breakItem.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                        
                }

                Text(breakItem.description)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // Duration
                VStack(alignment: .leading) {
                    HStack {
                        Text("DURATION")
                            .font(.caption)
                            .fontWeight(.bold)
                        Spacer()
                        Text("approx. \(breakItem.duration / 60) mins")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Exercise List
                VStack(alignment: .leading) {
                    HStack {
                        Text("EXERCISE LIST")
                            .font(.caption)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(breakItem.exercises.count) exercises")
                            .foregroundColor(.blue)
                    }
                    
                    ForEach(breakItem.exercises) { exercise in
                        HStack {
                            Image(exercise.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .padding(8)
                                .background(userTheme == .dark ? Color.gray.opacity(0.7) : .gray3, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .fontWeight(.bold)
                                Text(exercise.description)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
                
                NavigationLink(destination: StartExerciseView(breakItem: breakItem)) {
                        Text("Next")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                }
                .padding(.vertical, 50)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    
    }
}


struct DetailsBreakView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsBreakView(breakItem: breakList[0])
    }
}

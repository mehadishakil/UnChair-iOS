//
//  DetailsBreakView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI

struct DetailsBreakView: View {
    let breakItem: Break
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Title
                Text(breakItem.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Description
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
                            .foregroundColor(.purple)
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
                            .foregroundColor(.purple)
                    }

                    ForEach(breakItem.exercises) { exercise in
                        HStack {
                            Image(systemName: "figure.walk")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
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

                NavigationLink(destination: StartExerciseView(exercises: breakItem.exercises)) {
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.vertical, 50)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


struct DetailsBreakView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsBreakView(breakItem: breakList[0])
    }
}

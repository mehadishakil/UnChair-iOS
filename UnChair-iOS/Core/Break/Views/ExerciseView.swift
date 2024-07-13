//
//  ShortBreak.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 13/7/24.
//

import SwiftUI

struct ExerciseView: View {
    @State private var duration: Double = 3.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    // Add close action here
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            // Image
            Image("exerciseImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(16)
                .padding(.horizontal)
            
            // Title
            Text("Quick exercise")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Add to list
            HStack {
                Button(action: {
                    // Add action here
                }) {
                    Label("Add to list", systemImage: "bookmark")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Description
            Text("Activate your underworked glutes and prevent flat butt syndrome.")
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Duration
            VStack(alignment: .leading) {
                HStack {
                    Text("DURATION")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                    Text("approx. \(Int(duration)) mins")
                        .foregroundColor(.purple)
                }
                Slider(value: $duration, in: 1...10, step: 1)
                    .accentColor(.purple)
            }
            .padding(.horizontal)
            
            // Exercise List
            VStack(alignment: .leading) {
                HStack {
                    Text("EXERCISE LIST")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                    Text("3/12 exercises selected")
                        .foregroundColor(.purple)
                    Button(action: {
                        // Add shuffle action here
                    }) {
                        Image(systemName: "shuffle")
                            .foregroundColor(.purple)
                    }
                }
                
                ForEach(exercises, id: \.self) { exercise in
                    HStack {
                        Image(systemName: "figure.walk")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .fontWeight(.bold)
                            Text(exercise.duration)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            // Add action to reorder or modify exercise
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start button
            Button(action: {
                // Add start action here
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // Example exercise data
    var exercises = [
        Exercise(name: "Pulse Lunges", duration: "30 sec per side"),
        Exercise(name: "Power Skips", duration: "30 sec"),
        Exercise(name: "Single Legged Romanian Deadlifts", duration: "30 sec")
    ]
}

struct Exercise: Hashable {
    let name: String
    let duration: String
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}

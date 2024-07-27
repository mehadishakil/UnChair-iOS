//import SwiftUI
//
//struct ExerciseView: View {
//    @State private var duration: Double = 3.0
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                // Close button
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        // Add close action here
//                    }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                }
//                
//                // Image
//                Image("exerciseImage")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100, height: 100)
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//                
//                // Title
//                Text("Quick exercise")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//                
//                // Description
//                Text("Activate your underworked glutes and prevent flat butt syndrome.")
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//                
//                // Duration
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("DURATION")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                        Spacer()
//                        Text("approx. \(Int(duration)) mins")
//                            .foregroundColor(.purple)
//                    }
//                    
//                }
//                .padding(.horizontal)
//                
//                // Exercise List
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("EXERCISE LIST")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                        Spacer()
//                        Text("4 exercises")
//                            .foregroundColor(.purple)
//                        Button(action: {
//                            // Add shuffle action here
//                        }) {
//                            Image(systemName: "shuffle")
//                                .foregroundColor(.purple)
//                        }
//                    }
//                    
//                    ForEach(exercises, id: \.self) { exercise in
//                        HStack {
//                            Image(systemName: "figure.walk")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 50, height: 50)
//                                .cornerRadius(8)
//                            VStack(alignment: .leading) {
//                                Text(exercise.name)
//                                    .fontWeight(.bold)
//                                Text(exercise.duration)
//                                    .foregroundColor(.gray)
//                            }
//                            Spacer()
//                            Button(action: {
//                                // Add action to reorder or modify exercise
//                            }) {
//                                Image(systemName: "arrow.left.arrow.right")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding(.vertical, 8)
//                    }
//                }
//                .padding(.horizontal)
//                
//                Spacer()
//                
//                // Start button
//                Button(action: {
//                    // Add start action here
//                }) {
//                    Text("Start")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//        }
//    }
//    
//    // Example exercise data
//    var exercises = [
//        Exercise(name: "Pulse Lunges", duration: "30 sec per side"),
//        Exercise(name: "Power Skips", duration: "30 sec"),
//        Exercise(name: "Single Legged Romanian Deadlifts", duration: "30 sec"),
//        Exercise(name: "Nill down", duration: "30 sec per side"),
//        Exercise(name: "Biceps", duration: "30 sec"),
//        Exercise(name: "Triceps Deadlifts", duration: "30 sec")
//    ]
//}
//
//struct Exercise: Hashable {
//    let name: String
//    let duration: String
//}
//
//struct ExerciseView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseView()
//    }
//}



import SwiftUI

enum ExerciseType: String, CaseIterable {
  case quick = "Quick Exercise"
  case short = "Short Exercise"
  case medium = "Medium Exercise"
  case long = "Long Exercise"
}

struct Exercise: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let duration: String
  let image: String? // Optional image name for the exercise
}

struct ExerciseGroup {
  let type: ExerciseType
  let title: String? // Optional title for the group (e.g., "Warmup")
  let description: String
  let duration: Double // Duration in minutes
  let exercises: [Exercise]
}

struct ExerciseView: View {
  let exerciseGroup: ExerciseGroup

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
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

        if let image = exerciseGroup.exercises.first?.image {
          Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .cornerRadius(16)
            .padding(.horizontal)
        }

        Text(exerciseGroup.title ?? exerciseGroup.type.rawValue)
          .font(.title)
          .fontWeight(.bold)
          .padding(.horizontal)

        Text(exerciseGroup.description)
          .foregroundColor(.gray)
          .padding(.horizontal)

        VStack(alignment: .leading) {
          HStack {
            Text("DURATION")
              .font(.caption)
              .fontWeight(.bold)
            Spacer()
            Text("approx. \(Int(exerciseGroup.duration)) mins")
              .foregroundColor(.purple)
          }
        }
        .padding(.horizontal)

        VStack(alignment: .leading) {
          HStack {
            Text("EXERCISE LIST")
              .font(.caption)
              .fontWeight(.bold)
            Spacer()
            Text("\(exerciseGroup.exercises.count) exercises")
              .foregroundColor(.purple)
            Button(action: {
              // Add shuffle action here
            }) {
              Image(systemName: "shuffle")
                .foregroundColor(.purple)
            }
          }

          ForEach(exerciseGroup.exercises) { exercise in
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
  }
}

struct ExerciseView_Previews: PreviewProvider {
  static var previews: some View {
    let quickExercises = [
      Exercise(name: "Pulse Lunges", duration: "30 sec per side", image: "lunges"),
      Exercise(name: "Power Skips", duration: "30 sec", image: "skipping"),
    ]

    let quickExerciseGroup = ExerciseGroup(
      type: .quick,
      title: "Warmup",
      description: "Activate your body and get ready for the workout.",
      duration: 3.0,
      exercises: quickExercises
    )

    return ExerciseView(exerciseGroup: quickExerciseGroup)
  }
}

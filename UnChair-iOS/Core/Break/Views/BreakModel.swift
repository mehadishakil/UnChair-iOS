//
//  BreakModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//
import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let duration: Int
}

struct Break: Identifiable {
    let id = UUID()
    let title: String
    let image : String
    let overview: String
    let description: String
    let duration: Int
    let exercises: [Exercise]
}


let exercises: [Exercise] = [
    // Quick Break Exercises
    Exercise(name: "Neck Rolls", description: "Gently roll your neck in a circular motion.", duration: 15),
    Exercise(name: "Shoulder Shrugs", description: "Raise your shoulders towards your ears, then lower them.", duration: 15),
    Exercise(name: "Seated Torso Twist", description: "Sit straight, place your hand on the opposite knee, and twist your torso gently to each side.", duration: 30),
    Exercise(name: "Ankle Circles", description: "Rotate your ankles in a circular motion, both clockwise and counterclockwise.", duration: 30),
    Exercise(name: "Deep Breathing", description: "Take 3 deep breaths, inhaling through your nose and exhaling through your mouth.", duration: 30),

    // Short Break Exercises
    Exercise(name: "Wrist Stretches", description: "Extend your arms and rotate your wrists.", duration: 30),
    Exercise(name: "Standing Backbend", description: "Stand up and gently bend backwards, supporting your lower back.", duration: 30),
    Exercise(name: "Seated Leg Extensions", description: "Sit straight, extend one leg at a time, and hold for a few seconds.", duration: 60),
    Exercise(name: "Eye Rest", description: "Close your eyes and cover them with your palms for 20 seconds.", duration: 60),
    Exercise(name: "Shoulder Blade Squeeze", description: "Sit or stand, pull your shoulder blades together and hold.", duration: 60),
    Exercise(name: "Seated Marching", description: "While seated, lift your knees one at a time in a marching motion.", duration: 60),

    // Medium Break Exercises
    Exercise(name: "Leg Stretches", description: "Stretch your legs while seated or standing.", duration: 60),
    Exercise(name: "Standing Hamstring Stretch", description: "Stand, bend forward at the hips, and reach for your toes.", duration: 60),
    Exercise(name: "Wall Push-Ups", description: "Stand facing a wall, place your hands on it, and perform push-ups.", duration: 60),
    Exercise(name: "Seated Forward Bend", description: "Sit straight, extend your legs, and bend forward to touch your toes.", duration: 60),
    Exercise(name: "Calf Raises", description: "Stand on your toes and lower yourself slowly.", duration: 60),
    Exercise(name: "Seated Shoulder Stretch", description: "Cross one arm over your chest and gently pull it with the other.", duration: 60),
    Exercise(name: "Seated Side Stretch", description: "Sit and stretch your arms overhead, leaning to each side.", duration: 60),
    Exercise(name: "Deep Breathing", description: "Take 5 deep breaths, inhaling through your nose and exhaling through your mouth.", duration: 60),

    // Long Break Exercises
    Exercise(name: "Walk Around", description: "Take a short walk around your room or office.", duration: 300),
    Exercise(name: "Desk Push-ups", description: "Do 10 push-ups against your desk.", duration: 60),
    Exercise(name: "Chair Squats", description: "Stand up and sit down 10 times without fully sitting.", duration: 60),
    Exercise(name: "Seated Figure-Four Stretch", description: "Sit and place one ankle on the opposite knee, leaning forward.", duration: 60),
    Exercise(name: "Standing Quadriceps Stretch", description: "Stand, pull one foot towards your buttocks, and hold.", duration: 60),
    Exercise(name: "Seated Neck Stretch", description: "Sit and tilt your head towards your shoulder, holding gently.", duration: 60),
    Exercise(name: "Arm Circles", description: "Extend your arms and make circular motions, both forward and backward.", duration: 60),
    Exercise(name: "Standing Side Bend", description: "Stand, place one hand on your hip, and reach over your head to the opposite side.", duration: 60),
    Exercise(name: "Calf Stretch", description: "Place your hands on a wall, step one foot back, and press your heel down.", duration: 60),
    Exercise(name: "Meditation", description: "Sit comfortably, close your eyes, and focus on your breathing.", duration: 180)
]


// break list
let breakList: [Break] = [
    Break(
        title: "Quick Break",
        image: "quick_break",
        overview: "2-minute neck, shoulder, and ankle stretches to relieve tension.",
        description: "A quick session focusing on neck, shoulders, and ankle stretches to quickly relieve tension and improve circulation.",
        duration: 120,
        exercises: Array(exercises.prefix(5))
    ),
    Break(
        title: "Short Break", 
        image: "short_break",
        overview: "5-minute stretches for wrists, back, legs, and eyes.",
        description: "A brief yet effective series of stretches for wrists, back, legs, and eyes to reduce strain and refresh the mind.",
        duration: 300, 
        exercises: Array(exercises[5...10])
    ),
    Break(title: "Medium Break",
          image: "medium_break", 
          overview: "10-minute standing and seated exercises with deep breathing.",
          description: "A combination of standing and seated exercises targeting legs, shoulders, and back, paired with deep breathing for relaxation.",
          duration: 600,
          exercises: Array(exercises[11...18])
         ),
    Break(
        title: "Long Break",
        image: "long_break",
        overview: "20-minute routine of walking, stretching, and mindfulness.",
        description: "A comprehensive routine including walking, stretching, and mindfulness exercises to revitalize your body and mind for sustained productivity.",
        duration: 1200,
        exercises: Array(exercises[19...28])
    )
]

//
//  BreakModel.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 27/7/24.
//

import SwiftUI
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
    let description: String
    let duration: Int
    let exercises: [Exercise]
}


// Sample Exercises
let exercises: [Exercise] = [
    // quick exercise
    Exercise(name: "Neck Rolls", description: "Gently roll your neck in a circular motion.", duration: 15),
    Exercise(name: "Shoulder Shrugs", description: "Raise your shoulders towards your ears, then lower them.", duration: 15),
    // short exercise
    Exercise(name: "Wrist Stretches", description: "Extend your arms and rotate your wrists.", duration: 15),
    Exercise(name: "Standing Backbend", description: "Stand up and gently bend backwards, supporting your lower back.", duration: 15),
    // medium exercise
    Exercise(name: "Leg Stretches", description: "Stretch your legs while seated or standing.", duration: 15),
    Exercise(name: "Eye Rest", description: "Close your eyes and cover them with your palms for 20 seconds.", duration: 15),
    Exercise(name: "Deep Breathing", description: "Take 5 deep breaths, inhaling through your nose and exhaling through your mouth.", duration: 15),
    // long Exercise
    Exercise(name: "Walk Around", description: "Take a short walk around your room or office.", duration: 15),
    Exercise(name: "Desk Push-ups", description: "Do 10 push-ups against your desk.", duration: 15),
    Exercise(name: "Chair Squats", description: "Stand up and sit down 10 times without fully sitting.", duration: 15)
]

// break list
let breakList: [Break] = [
    Break(title: "Quick Break", description: "A fast stretch session", duration: 60, exercises: Array(exercises.prefix(2))),
    Break(title: "Short Break", description: "Quick mindfulness practice", duration: 120, exercises: [exercises[6]]),
    Break(title: "Medium Break", description: "Combination of stretches and breathing exercises", duration: 360, exercises: [exercises[0], exercises[1], exercises[6]]),
    Break(title: "Long Break", description: "Comprehensive break for full body and mind", duration: 600, exercises: exercises)
]

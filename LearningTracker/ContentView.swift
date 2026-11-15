//
//  ContentView.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//


import SwiftUI

struct ContentView: View {

    @AppStorage("learningGoalSubject") private var savedGoalSubject = ""
    @AppStorage("learningGoalDuration") private var savedGoalDuration = "Week"

    var body: some View {
        NavigationStack {
            if savedGoalSubject.isEmpty {
                OnboardingView()
            } else {
                ActivityView(
                    learningGoal: LearningGoal(
                        subject: savedGoalSubject,
                        duration: savedGoalDuration
                    )
                )
            }
        }
        // Orange alert buttons ("Update") like the prototype
        .tint(Color("orange"))
    }
}

#Preview {
    ContentView()
}

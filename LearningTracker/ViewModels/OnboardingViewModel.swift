//
//  OnboardingViewModel.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//

//
//  OnboardingViewModel.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//


import Foundation
import Combine

class OnboardingViewModel: ObservableObject {

    @Published var learningGoal = ""
    @Published var selectedDuration = "Week"

    init(existingGoal: LearningGoal? = nil) {
        learningGoal = existingGoal?.subject ?? ""
        selectedDuration = existingGoal?.duration ?? "Week"
    }

    func createGoal() -> LearningGoal {
        return LearningGoal(
            subject: learningGoal.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            duration: selectedDuration
        )
    }

    // Saves the first goal (used by Onboarding's "Start Learning").
    // ContentView watches these same keys, so saving them is enough
    // to make the app switch to the Activity page by itself.
    func saveGoal() {
        let goal = createGoal()

        UserDefaults.standard.set(goal.subject, forKey: "learningGoalSubject")
        UserDefaults.standard.set(goal.duration, forKey: "learningGoalDuration")
    }
}

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

    let isEditing: Bool

    private let originalGoal: LearningGoal?

    init(existingGoal: LearningGoal? = nil) {
        originalGoal = existingGoal
        isEditing = existingGoal != nil

        learningGoal = existingGoal?.subject ?? ""
        selectedDuration = existingGoal?.duration ?? "Week"
    }

    func createGoal() -> LearningGoal {
        return LearningGoal(
            subject: learningGoal,
            duration: selectedDuration
        )
    }

    var hasGoalChanged: Bool {
        guard let originalGoal else {
            return false
        }

        return learningGoal != originalGoal.subject ||
               selectedDuration != originalGoal.duration
    }
}


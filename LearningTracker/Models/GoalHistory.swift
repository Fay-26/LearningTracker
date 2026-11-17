//
//  GoalHistory.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 17/11/2026.
//


import Foundation

struct GoalHistory: Codable, Identifiable {

    var id = UUID()
    let learningGoal: LearningGoal
    let startDate: Date
    let endDate: Date
    let records: [ActivityRecord]

}

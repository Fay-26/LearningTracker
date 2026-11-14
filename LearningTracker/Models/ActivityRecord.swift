//
//  ActivityRecord.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 12/11/2026.
//

import Foundation

enum ActivityStatus: String, Codable {
    case learned
    case frozen
}

struct ActivityRecord: Identifiable, Codable {

    var id: String {
        date.formatted(.iso8601.year().month().day())
    }

    let date: Date
    let status: ActivityStatus
}

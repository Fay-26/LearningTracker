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
    let subject: String?
    let duration: String?

    init(
        date: Date,
        status: ActivityStatus,
        subject: String? = nil,
        duration: String? = nil
    ) {
        self.date = date
        self.status = status
        self.subject = subject
        self.duration = duration
    }

    // Keeps older saved records compatible
    enum CodingKeys: String, CodingKey {
        case date, status, subject, duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        date = try container.decode(Date.self, forKey: .date)
        status = try container.decode(ActivityStatus.self, forKey: .status)
        subject = try container.decodeIfPresent(String.self, forKey: .subject)
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
    }
}

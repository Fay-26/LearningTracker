//
//  ActivityViewModel.swift
//  LearningTracker
//
//  Created by Fay Alabdulqader on 10/11/2026.
//
import Foundation
import Combine

class ActivityViewModel: ObservableObject {

    @Published var learningGoal: LearningGoal

    private let storageKey = "activityRecords"
    private let streakResetKey = "streakResetDate"
    private let goalStartDateKey = "goalStartDate"

    @Published private(set) var records: [ActivityRecord] = []

    @Published var learnedDays = 0
    @Published var frozenDays = 0
    @Published var hasLearnedToday = false
    @Published var hasFrozenToday = false
    @Published private(set) var currentStreak = 0

    private var streakResetDate: Date?
    @Published private(set) var goalStartDate: Date

    // Maximum freezes
    var maximumFreezes: Int {
        switch learningGoal.duration {
        case "Week": return 2
        case "Month": return 8
        case "Year": return 96
        default: return 2
        }
    }

    // Freezes used during the current goal period
    var freezesUsed: Int {
        records.filter {
            $0.status == .frozen &&
            $0.date >= goalStartDate &&
            $0.date < goalEndDate
        }.count
    }

    var canFreeze: Bool {
        freezesUsed < maximumFreezes &&
        !hasLearnedToday &&
        !hasFrozenToday
    }

    // Goal end date
    var goalEndDate: Date {
        let calendar = Calendar.current

        switch learningGoal.duration {
        case "Week":
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: goalStartDate
            ) ?? goalStartDate

        case "Month":
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: goalStartDate
            ) ?? goalStartDate

        case "Year":
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: goalStartDate
            ) ?? goalStartDate

        default:
            return goalStartDate
        }
    }

    // Has the goal period ended?
    var isGoalPeriodFinished: Bool {
        Date() >= goalEndDate
    }

    // Did the user learn every day?
    var isGoalCompleted: Bool {
        guard isGoalPeriodFinished else {
            return false
        }

        let calendar = Calendar.current
        var date = goalStartDate

        while date < goalEndDate {

            let learnedOnThisDay = records.contains { record in
                calendar.isDate(record.date, inSameDayAs: date) &&
                record.status == .learned
            }

            if !learnedOnThisDay {
                return false
            }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            ) else {
                return false
            }

            date = nextDate
        }

        return true
    }

    init(learningGoal: LearningGoal) {
        self.learningGoal = learningGoal

        // Save the learning goal
        UserDefaults.standard.set(
            learningGoal.subject,
            forKey: "learningGoalSubject"
        )

        UserDefaults.standard.set(
            learningGoal.duration,
            forKey: "learningGoalDuration"
        )

        self.streakResetDate = UserDefaults.standard.object(
            forKey: streakResetKey
        ) as? Date

        self.goalStartDate = UserDefaults.standard.object(
            forKey: goalStartDateKey
        ) as? Date ?? Calendar.current.startOfDay(for: Date())

        UserDefaults.standard.set(
            goalStartDate,
            forKey: goalStartDateKey
        )

        loadRecords()
        refresh()
    }

    // Load saved records
    private func loadRecords() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let savedRecords = try? JSONDecoder().decode(
                [ActivityRecord].self,
                from: data
            )
        else {
            return
        }

        records = savedRecords
        updateCounts()
        updateStreak()
    }

    // Save records
    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(records) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    // Update daily counts and today's status
    private func updateCounts() {

        let currentGoalRecords = records.filter {
            $0.date >= goalStartDate &&
            $0.date < goalEndDate
        }

        learnedDays = currentGoalRecords.filter {
            $0.status == .learned
        }.count

        frozenDays = currentGoalRecords.filter {
            $0.status == .frozen
        }.count

        let today = Calendar.current.startOfDay(for: Date())

        hasLearnedToday = currentGoalRecords.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today) &&
            $0.status == .learned
        }

        hasFrozenToday = currentGoalRecords.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today) &&
            $0.status == .frozen
        }
    }

    // Calculate streak
    private func updateStreak() {
        let sortedRecords = records
            .filter { record in
                guard let streakResetDate else {
                    return true
                }

                return record.date > streakResetDate
            }
            .sorted {
                $0.date < $1.date
            }

        guard let lastRecord = sortedRecords.last else {
            currentStreak = 0
            return
        }

        let hoursSinceLastActivity = Date().timeIntervalSince(
            lastRecord.date
        )

        if hoursSinceLastActivity > 32 * 60 * 60 {
            currentStreak = 0
            return
        }

        var streak = 1
        var index = sortedRecords.count - 1

        while index > 0 {
            let currentDate = sortedRecords[index].date
            let previousDate = sortedRecords[index - 1].date

            if currentDate.timeIntervalSince(previousDate) <= 32 * 60 * 60 {
                streak += 1
                index -= 1
            } else {
                break
            }
        }

        currentStreak = streak
    }

    // Refresh daily status and streak
    func refresh() {
        updateCounts()
        updateStreak()
    }

    func refreshStreak() {
        updateStreak()
    }

    // Get activity status for a calendar date
    func status(for date: Date) -> ActivityStatus? {
        return records.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }?.status
    }

    // Update goal and reset streak, freezes and goal period
    func updateLearningGoal(_ newGoal: LearningGoal) {
        learningGoal = newGoal

        // Save updated learning goal
        UserDefaults.standard.set(
            newGoal.subject,
            forKey: "learningGoalSubject"
        )

        UserDefaults.standard.set(
            newGoal.duration,
            forKey: "learningGoalDuration"
        )

   

        streakResetDate = Date()

        UserDefaults.standard.set(
            streakResetDate,
            forKey: streakResetKey
        )

        goalStartDate = Calendar.current.startOfDay(for: Date())

        UserDefaults.standard.set(
            goalStartDate,
            forKey: goalStartDateKey
        )

        currentStreak = 0
        refresh()
    }

    // Log as learned
    func logAsLearned() {
        refresh()

        guard !hasLearnedToday && !hasFrozenToday else {
            return
        }

        let newRecord = ActivityRecord(
            date: Date(),
            status: .learned
        )

        records.append(newRecord)
        saveRecords()
        refresh()
    }

    // Freeze a day
    func freezeDay() {
        refresh()

        guard canFreeze else {
            return
        }

        let newRecord = ActivityRecord(
            date: Date(),
            status: .frozen
        )

        records.append(newRecord)
        saveRecords()
        refresh()
    }
}

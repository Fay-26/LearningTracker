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
    private let goalHistoryKey = "goalHistory"

    // Allows testing with separate storage and simulated time
    private let defaults: UserDefaults
    private let now: () -> Date

    @Published private(set) var records: [ActivityRecord] = []
    @Published private(set) var goalHistory: [GoalHistory] = []

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

        !isGoalPeriodFinished &&
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

    // The app's "now" (real time, or simulated time from the Debug Panel).
    // Views use this instead of Date() so everything follows the same clock.
    var currentDate: Date {
        now()
    }

    // Has the goal period ended?
    var isGoalPeriodFinished: Bool {
        now() >= goalEndDate
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

    init(
        learningGoal: LearningGoal,
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { Date() }
    ) {

        self.learningGoal = learningGoal
        self.defaults = defaults
        self.now = now

        // Save the learning goal
        defaults.set(
            learningGoal.subject,
            forKey: "learningGoalSubject"
        )

        defaults.set(
            learningGoal.duration,
            forKey: "learningGoalDuration"
        )

        self.streakResetDate = defaults.object(
            forKey: streakResetKey
        ) as? Date

        self.goalStartDate = defaults.object(
            forKey: goalStartDateKey
        ) as? Date ?? Calendar.current.startOfDay(for: now())

        defaults.set(
            goalStartDate,
            forKey: goalStartDateKey
        )

        loadRecords()
        loadGoalHistory()
        refresh()
    }

    // Load saved records
    private func loadRecords() {

        guard
            let data = defaults.data(forKey: storageKey),
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

        defaults.set(data, forKey: storageKey)
    }

    // Load saved goal history
    private func loadGoalHistory() {

        guard
            let data = defaults.data(forKey: goalHistoryKey),
            let savedHistory = try? JSONDecoder().decode(
                [GoalHistory].self,
                from: data
            )
        else {
            return
        }

        goalHistory = savedHistory
    }

    // Save goal history
    private func saveGoalHistory() {

        guard let data = try? JSONEncoder().encode(goalHistory) else {
            return
        }

        defaults.set(data, forKey: goalHistoryKey)
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

        let today = Calendar.current.startOfDay(for: now())

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

        let hoursSinceLastActivity = now().timeIntervalSince(
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

    // Get activity status for a calendar date
    func status(for date: Date) -> ActivityStatus? {

        return records.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }?.status
    }

    // MARK: - Week strip helpers

    // The 7 dates of the current week (follows the app's clock)
    var currentWeekDates: [Date] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)

        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: week.start)
        }
    }

    // MARK: - Calendar helpers

    // All activity (previous goals + current goal), oldest → newest
    var allRecords: [ActivityRecord] {

        let previousRecords = goalHistory.flatMap {
            $0.records
        }

        return (previousRecords + records)
            .sorted { $0.date < $1.date }
    }

    // The record shown on a calendar day.
    // Records are sorted oldest → newest, so `last` picks the
    // newest one if a day has two (e.g. logged, changed goal, logged again)
    func record(for date: Date) -> ActivityRecord? {

        allRecords.last {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    // Is this date inside the current goal period?
    func isInCurrentGoalPeriod(_ date: Date) -> Bool {

        date >= Calendar.current.startOfDay(for: goalStartDate) &&
        date < goalEndDate
    }

    // All months from the first activity through December
    // of the current year, with at least one full calendar year
    var calendarMonths: [Date] {

        let calendar = Calendar.current

        let currentYear = calendar.component(.year, from: currentDate)

        guard
            let january = calendar.date(
                from: DateComponents(
                    year: currentYear,
                    month: 1,
                    day: 1
                )
            ),
            let december = calendar.date(
                from: DateComponents(
                    year: currentYear,
                    month: 12,
                    day: 1
                )
            )
        else {
            return []
        }

        let firstActivity = allRecords
            .map { $0.date }
            .min()

        let firstMonth = firstActivity.flatMap {
            calendar.dateInterval(of: .month, for: $0)?.start
        } ?? january

        let startMonth = min(firstMonth, january)

        let monthCount = calendar.dateComponents(
            [.month],
            from: startMonth,
            to: december
        ).month ?? 0

        return (0...max(0, monthCount)).compactMap {
            calendar.date(
                byAdding: .month,
                value: $0,
                to: startMonth
            )
        }
    }

    // Get historical subject if an older record has no subject saved
    func subject(for record: ActivityRecord) -> String {

        if let subject = record.subject {
            return subject
        }

        let historicalGoal = goalHistory.first {
            $0.records.contains { $0.id == record.id }
        }

        return historicalGoal?.learningGoal.subject
            ?? learningGoal.subject
    }

    // Get historical duration if an older record has no duration saved
    func duration(for record: ActivityRecord) -> String {

        if let duration = record.duration {
            return duration
        }

        let historicalGoal = goalHistory.first {
            $0.records.contains { $0.id == record.id }
        }

        return historicalGoal?.learningGoal.duration
            ?? learningGoal.duration
    }

    // Archive the current goal before starting a new one
    private func archiveCurrentGoal() {

        let archiveDate = min(now(), goalEndDate)

        // `records` only ever holds the current goal's activity,
        // so we archive all of it. Filtering here could drop a record
        // and it would then be lost when `records` is cleared.
        let history = GoalHistory(
            learningGoal: learningGoal,
            startDate: goalStartDate,
            endDate: archiveDate,
            records: records
        )

        goalHistory.append(history)

        saveGoalHistory()
    }

    // Update goal and reset streak and goal period
    func updateLearningGoal(_ newGoal: LearningGoal) {

        // Save the previous goal before changing it
        archiveCurrentGoal()

        // Clear records for the new active goal
        records = []
        saveRecords()

        learningGoal = newGoal

        // Save updated learning goal
        defaults.set(
            newGoal.subject,
            forKey: "learningGoalSubject"
        )

        defaults.set(
            newGoal.duration,
            forKey: "learningGoalDuration"
        )

        streakResetDate = now()

        defaults.set(
            streakResetDate,
            forKey: streakResetKey
        )

        goalStartDate = Calendar.current.startOfDay(for: now())

        defaults.set(
            goalStartDate,
            forKey: goalStartDateKey
        )

        currentStreak = 0

        refresh()
    }

    // Log as learned
    func logAsLearned() {

        refresh()

        // No logging after the goal period has ended,
        // or if something was already logged today
        guard
            !isGoalPeriodFinished,
            !hasLearnedToday,
            !hasFrozenToday
        else {
            return
        }

        let newRecord = ActivityRecord(
            date: now(),
            status: .learned,
            subject: learningGoal.subject,
            duration: learningGoal.duration
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
            date: now(),
            status: .frozen,
            subject: learningGoal.subject,
            duration: learningGoal.duration
        )

        records.append(newRecord)

        saveRecords()
        refresh()
    }
}

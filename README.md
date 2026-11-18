## Learning Tracker
<p align="center">
  <img src="https://github.com/user-attachments/assets/97ad0478-fb6b-414f-be63-d8f6fe0efb9c" alt="LearningTracker — Build a daily learning habit, one day at a time." width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-27.0%2B-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 27.0+">
  <img src="https://img.shields.io/badge/Swift-5-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5">
  <img src="https://img.shields.io/badge/SwiftUI-MVVM-FF9230?style=for-the-badge" alt="SwiftUI · MVVM">
</p>

<p align="center">
  <a href="#overview"><b>Overview</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#screenshots"><b>Screenshots</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#features"><b>Features</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#how-it-works"><b>How It Works</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#architecture"><b>Architecture</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#getting-started"><b>Getting Started</b></a>
</p>

<br>

## Overview

**LearningTracker** helps you stay consistent with something you want to learn: Swift, piano, drawing, a new language, anything.

Pick **one goal**, commit for a **week, a month, or a year**, and check in every day. Learned today? Log it. Need a break? **Freeze** the day and keep your streak alive. When the goal ends, the app tells you whether you made it.

> **Consistency without pressure.** Missing one day shouldn't feel like losing everything.

<br>

## Screenshots

<table align="center">
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/47deabbe-d4d6-49f9-a289-67a7fa79f969" alt="Set a goal" width="250"><br><sub><b>Set a goal</b></sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/63eb214c-e56d-4b2f-bdd4-81840593f7e7" alt="Log today as learned" width="250"><br><sub><b>Log your day</b></sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/e87c9de4-df9d-4741-aa7c-2cc7912dfbc9" alt="Freeze a day" width="250"><br><sub><b>Freeze a day</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/5a3d1e3a-2704-4282-91b9-f471987acc65" alt="Activity calendar" width="250"><br><sub><b>Your calendar</b></sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/f0556cba-f77f-41f0-99f4-5ca79de7cb9a" alt="Goal complete" width="250"><br><sub><b>Goal results</b></sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/c7741f6b-42ff-4bdd-a405-9c3b432fd8a8" alt="Edit your goal" width="250"><br><sub><b>Edit your goal</b></sub></td>
  </tr>
</table>

<br>

## Features

<table>
  <tr>
    <td width="50%" valign="top">
      <b>One Clear Goal</b><br>
      <sub>Choose a subject and commit for a week, a month, or a year.</sub>
    </td>
    <td width="50%" valign="top">
      <b>Daily Check-In</b><br>
      <sub>Log today as <b>Learned</b> with a single tap.</sub>
    </td>
  </tr>
  <tr>
    <td valign="top">
      <b>Freeze Days</b><br>
      <sub>Take a break without breaking your streak: 2, 8, or 96 per goal.</sub>
    </td>
    <td valign="top">
      <b>Progress at a Glance</b><br>
      <sub>This week's days, plus your learned and frozen counts.</sub>
    </td>
  </tr>
  <tr>
    <td valign="top">
      <b>Activity Calendar</b><br>
      <sub>Every learned and frozen day, including past goals. Tap a day for details.</sub>
    </td>
    <td valign="top">
      <b>Goal Results</b><br>
      <sub>A clear success or try-again screen when the goal period ends.</sub>
    </td>
  </tr>
  <tr>
    <td valign="top">
      <b>Flexible Goals</b><br>
      <sub>Change your goal anytime. The old one is archived, not deleted.</sub>
    </td>
    <td valign="top">
      <b>Always Saved</b><br>
      <sub>Your goal, activity, and history stay saved when you close the app.</sub>
    </td>
  </tr>
</table>

<br>

## How It Works

### 1 · Set a Goal

Type what you want to learn and choose a duration. The goal starts at **12:00 AM on the day you create it** and ends on a real calendar date.

| Duration | Goal Period | Example (starts Nov 18) | Freezes |
|:--|:--|:--|:--:|
| **Week** | 7 days | Nov 18 – Nov 24 | 2 |
| **Month** | 1 calendar month | Nov 18 – Dec 17 | 8 |
| **Year** | 1 calendar year | Nov 18 – Nov 17 next year | 96 |

### 2 · Check In Once a Day

| Button | Result |
|:--|:--|
| **Log as Learned** | Today is saved as `learned` and the **Learned** count goes up. |
| **Freeze for a day** | Today is saved as `frozen`, the **Freezed** count goes up, and one freeze is used. |

- **One activity per day:** after either action, both buttons lock for the rest of the day.
- **Midnight unlock:** the buttons unlock again at **12:00 AM**. The app re-checks every minute and when you return to it.
- **Freeze limit:** **Freeze for a day** is disabled once all freezes for the goal are used.
- **After the goal ends:** logging and freezing stop.

### 3 · Keep Your Streak

Learned **and** frozen days both keep your streak going, as long as **no more than 32 hours** pass between one activity and the next.

| Activity | Time since previous | Streak |
|:--|:--|:--:|
| Mon 8 PM · Learned | – | 1 |
| Tue 8 PM · Frozen | 24 hours | 2 |
| Wed 10 PM · Learned | 26 hours | 3 |

The streak resets to **0** if more than 32 hours pass, or when you update your goal.

### 4 · Finish the Goal

When the goal period ends, the home screen shows your result:

| Result | When |
|:--|:--|
| **Well done!** | You logged **Learned** on **every** day of the goal. |
| **You didn't reach your goal this time.** | At least one day wasn't learned. |

> **Frozen days protect your streak, but they don't count as learned days.**
> For a week: 7 learned = completed · 6 learned + 1 frozen = not completed.

Tap **Set a goal** to start the next one.

### 5 · Change Your Goal

Tap the edit icon, change the subject or duration, and confirm **Update**. The app archives the current goal with all its days, then starts a fresh one from today with a new streak, counts, and freezes. If nothing changed, nothing is reset.

<br>

## Architecture

LearningTracker uses **MVVM**: views draw the screens, view models hold the logic, and models describe the data.


<p align="center">
  <sub>Made with SwiftUI by <a href="https://github.com/Fay-26"><b>Fay Alabdulqader</b></a></sub>
</p><img width="2400" height="1500" alt="architecture" src="https://github.com/user-attachments/assets/d3aaa2e0-8022-44d0-8391-6a8723de9a93" />


| Layer | Responsibility |
|:--|:--|
| **Models** | Plain data: `LearningGoal`, `ActivityRecord` (+ `ActivityStatus`), `GoalHistory` |
| **ViewModels** | `ActivityViewModel` handles logging, freezes, the streak, goal dates, completion, archiving, and saving. `OnboardingViewModel` builds and saves the first goal. |
| **Views** | Display data and pass taps to the view models. No business rules. |

<details>
<summary><b>Project Structure</b></summary>
<br>

```text
LearningTracker/
├── LearningTracker.xcodeproj
├── architecture.png
└── LearningTracker/
    ├── LearningTrackerApp.swift      # App entry (dark mode)
    ├── ContentView.swift             # Onboarding or Activity
    ├── Models/
    │   ├── LearningGoal.swift        # Subject + duration
    │   ├── ActivityRecord.swift      # One learned / frozen day
    │   ├── GoalHistory.swift         # An archived goal
    │   └── DebugPanel.swift          # Debug-only testing panel
    ├── ViewModels/
    │   ├── ActivityViewModel.swift   # Core app logic
    │   └── OnboardingViewModel.swift # Goal form + first save
    ├── Views/
    │   ├── OnboardingView.swift
    │   ├── ActivityView.swift        # Home screen
    │   ├── CalendarView.swift
    │   ├── EditLearningGoalView.swift
    │   ├── GoalResultView.swift
    │   └── Components.swift          # Shared UI pieces
    ├── Assets.xcassets               # apporange, appblue
    └── learning.icon                 # App icon
```

</details>

<details>
<summary><b>Data Models</b></summary>
<br>

| Model | Properties |
|:--|:--|
| `LearningGoal` | `subject: String`, `duration: String` (`"Week"`, `"Month"`, `"Year"`) |
| `ActivityRecord` | `date: Date`, `status: ActivityStatus`, `subject: String?`, `duration: String?`. `Codable` and `Identifiable`; the `id` is the day, e.g. `2026-11-18`. |
| `ActivityStatus` | `.learned`, `.frozen` |
| `GoalHistory` | `id: UUID`, `learningGoal`, `startDate`, `endDate`, `records: [ActivityRecord]` |

</details>

<details>
<summary><b>Shared UI Components</b></summary>
<br>

All in `Components.swift`.

| Component | Purpose |
|:--|:--|
| `ActivityHeader` | **Activity** title, date, and the top-right icons |
| `GlassIcon` | Round glass icon buttons |
| `OrangeButtonLabel` | Orange capsule buttons (**Start Learning**, **Set a goal**) |
| `GoalForm` | Goal text field + Week / Month / Year picker |
| `WeekStripView` / `DayCircle` | This week's days: orange = learned, blue = frozen |
| `StatCard` / `StatCards` | **Learned** and **Freezed** counters |

</details>

<details>
<summary><b>Data Persistence</b></summary>
<br>

Everything is stored **on the device** in `UserDefaults`. Lists are saved as JSON with `Codable`.

| Key | Stores |
|:--|:--|
| `learningGoalSubject` / `learningGoalDuration` | The current goal |
| `goalStartDate` | When the current goal started |
| `activityRecords` | The current goal's learned and frozen days |
| `streakResetDate` | When the streak was last reset by a goal update |
| `goalHistory` | All archived goals and their days |

When you update a goal, its records are **moved into `goalHistory`** before the current list is cleared. The calendar shows both.

</details>

<br>

## Tech Stack

| | |
|:--|:--|
| **UI** | SwiftUI with Liquid Glass (`glassEffect`) |
| **Architecture** | MVVM |
| **State** | Combine: `ObservableObject`, `@Published`, `Timer.publish` |
| **Storage** | `UserDefaults` + `Codable` (JSON) |
| **Target** | iOS 27.0+ · iPhone & iPad · Swift 5 language mode |
| **Dependencies** | None. Apple frameworks only. |

<br>

## Getting Started

**Requirements:** a Mac with **Xcode 27** or later, and an iOS 27 Simulator or device.

```bash
git clone https://github.com/Fay-26/LearningTracker.git
cd LearningTracker
open LearningTracker.xcodeproj
```

Choose an iPhone Simulator in the Xcode toolbar and press **Command + R**.

> **On a real device:** in **Signing & Capabilities**, select your own **Team**. If Xcode reports a conflict, change the **Bundle Identifier**.

<br>

---

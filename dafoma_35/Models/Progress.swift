//
//  Progress.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation

struct DailyProgress: Codable, Identifiable {
    let id: UUID
    let date: Date
    var questsCompleted: Int
    var pointsEarned: Int
    var timeSpentMinutes: Int
    var categoriesEngaged: Set<QuestCategory>
    var streak: Int
    
    init(date: Date) {
        self.id = UUID()
        self.date = date
        self.questsCompleted = 0
        self.pointsEarned = 0
        self.timeSpentMinutes = 0
        self.categoriesEngaged = []
        self.streak = 0
    }
}

struct WeeklyProgress: Codable, Identifiable {
    let id: UUID
    let weekStartDate: Date
    var dailyProgress: [DailyProgress]
    var totalQuestsCompleted: Int
    var totalPointsEarned: Int
    var totalTimeSpentMinutes: Int
    var averageQuestsPerDay: Double
    var mostActiveCategory: QuestCategory?
    
    init(weekStartDate: Date) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.dailyProgress = []
        self.totalQuestsCompleted = 0
        self.totalPointsEarned = 0
        self.totalTimeSpentMinutes = 0
        self.averageQuestsPerDay = 0.0
        self.mostActiveCategory = nil
        
        // Initialize daily progress for the week
        let calendar = Calendar.current
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStartDate) {
                dailyProgress.append(DailyProgress(date: date))
            }
        }
    }
    
    mutating func updateProgress() {
        totalQuestsCompleted = dailyProgress.reduce(0) { $0 + $1.questsCompleted }
        totalPointsEarned = dailyProgress.reduce(0) { $0 + $1.pointsEarned }
        totalTimeSpentMinutes = dailyProgress.reduce(0) { $0 + $1.timeSpentMinutes }
        averageQuestsPerDay = Double(totalQuestsCompleted) / 7.0
        
        // Find most active category
        var categoryCount: [QuestCategory: Int] = [:]
        for day in dailyProgress {
            for category in day.categoriesEngaged {
                categoryCount[category, default: 0] += 1
            }
        }
        mostActiveCategory = categoryCount.max(by: { $0.value < $1.value })?.key
    }
}

struct MonthlyProgress: Codable, Identifiable {
    let id: UUID
    let month: Int
    let year: Int
    var weeklyProgress: [WeeklyProgress]
    var totalQuestsCompleted: Int
    var totalPointsEarned: Int
    var totalTimeSpentHours: Double
    var longestStreak: Int
    var categoriesEngaged: [QuestCategory: Int]
    var achievements: [Achievement]
    
    init(month: Int, year: Int) {
        self.id = UUID()
        self.month = month
        self.year = year
        self.weeklyProgress = []
        self.totalQuestsCompleted = 0
        self.totalPointsEarned = 0
        self.totalTimeSpentHours = 0.0
        self.longestStreak = 0
        self.categoriesEngaged = [:]
        self.achievements = []
    }
    
    mutating func updateProgress() {
        totalQuestsCompleted = weeklyProgress.reduce(0) { $0 + $1.totalQuestsCompleted }
        totalPointsEarned = weeklyProgress.reduce(0) { $0 + $1.totalPointsEarned }
        totalTimeSpentHours = Double(weeklyProgress.reduce(0) { $0 + $1.totalTimeSpentMinutes }) / 60.0
        
        // Calculate categories engaged
        categoriesEngaged = [:]
        for week in weeklyProgress {
            for day in week.dailyProgress {
                for category in day.categoriesEngaged {
                    categoriesEngaged[category, default: 0] += 1
                }
            }
        }
        
        // Calculate longest streak
        var currentStreak = 0
        var maxStreak = 0
        
        for week in weeklyProgress {
            for day in week.dailyProgress {
                if day.questsCompleted > 0 {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    currentStreak = 0
                }
            }
        }
        longestStreak = maxStreak
    }
}

struct ProgressStats: Codable {
    var totalQuestsCompleted: Int
    var totalPointsEarned: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalTimeSpentHours: Double
    var level: Int
    var experiencePoints: Int
    var experienceToNextLevel: Int
    var favoriteCategory: QuestCategory?
    var averageQuestsPerWeek: Double
    var completionRate: Double // Percentage of started quests completed
    
    init() {
        self.totalQuestsCompleted = 0
        self.totalPointsEarned = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalTimeSpentHours = 0.0
        self.level = 1
        self.experiencePoints = 0
        self.experienceToNextLevel = 100
        self.favoriteCategory = nil
        self.averageQuestsPerWeek = 0.0
        self.completionRate = 0.0
    }
    
    mutating func updateLevel() {
        // Level up system: every 100 points = 1 level
        let newLevel = (totalPointsEarned / 100) + 1
        if newLevel > level {
            level = newLevel
        }
        
        experiencePoints = totalPointsEarned % 100
        experienceToNextLevel = 100 - experiencePoints
    }
}

// Sample data for testing
extension ProgressStats {
    static let sample: ProgressStats = {
        var stats = ProgressStats()
        stats.totalQuestsCompleted = 47
        stats.totalPointsEarned = 685
        stats.currentStreak = 5
        stats.longestStreak = 12
        stats.totalTimeSpentHours = 23.5
        stats.level = 7
        stats.experiencePoints = 85
        stats.experienceToNextLevel = 15
        stats.favoriteCategory = .mindfulness
        stats.averageQuestsPerWeek = 6.7
        stats.completionRate = 0.89
        return stats
    }()
}

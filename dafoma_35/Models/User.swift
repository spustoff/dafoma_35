//
//  User.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var profileImageURL: String?
    var joinedDate: Date
    var currentStreak: Int
    var longestStreak: Int
    var totalQuestsCompleted: Int
    var totalPoints: Int
    var level: Int
    var preferences: UserPreferences
    var achievements: [Achievement]
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.profileImageURL = nil
        self.joinedDate = Date()
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalQuestsCompleted = 0
        self.totalPoints = 0
        self.level = 1
        self.preferences = UserPreferences()
        self.achievements = []
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var mindfulBreaksEnabled: Bool = true
    var breakInterval: TimeInterval = 3600 // 1 hour
    var preferredQuestCategories: [QuestCategory] = [.lifestyle, .productivity]
    var darkModeEnabled: Bool = false
    
    init() {}
    
    init(notificationsEnabled: Bool, mindfulBreaksEnabled: Bool, breakInterval: TimeInterval, preferredQuestCategories: [QuestCategory], darkModeEnabled: Bool) {
        self.notificationsEnabled = notificationsEnabled
        self.mindfulBreaksEnabled = mindfulBreaksEnabled
        self.breakInterval = breakInterval
        self.preferredQuestCategories = preferredQuestCategories
        self.darkModeEnabled = darkModeEnabled
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockedDate: Date?
    let pointsReward: Int
    
    init(title: String, description: String, iconName: String, pointsReward: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.iconName = iconName
        self.unlockedDate = nil
        self.pointsReward = pointsReward
    }
}

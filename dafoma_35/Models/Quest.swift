//
//  Quest.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation

enum QuestCategory: String, CaseIterable, Codable {
    case lifestyle = "Lifestyle"
    case productivity = "Productivity"
    case mindfulness = "Mindfulness"
    case fitness = "Fitness"
    case learning = "Learning"
    case creativity = "Creativity"
    case social = "Social"
}

enum QuestDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var points: Int {
        switch self {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        }
    }
}

enum QuestStatus: String, Codable {
    case available = "Available"
    case inProgress = "In Progress"
    case completed = "Completed"
    case skipped = "Skipped"
}

struct Quest: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: QuestCategory
    let difficulty: QuestDifficulty
    let estimatedDuration: TimeInterval
    let iconName: String
    var status: QuestStatus
    var startDate: Date?
    var completedDate: Date?
    let createdDate: Date
    var progress: Double // 0.0 to 1.0
    
    init(title: String, description: String, category: QuestCategory, difficulty: QuestDifficulty, estimatedDuration: TimeInterval, iconName: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.iconName = iconName
        self.status = .available
        self.startDate = nil
        self.completedDate = nil
        self.createdDate = Date()
        self.progress = 0.0
    }
    
    var points: Int {
        return difficulty.points
    }
    
    mutating func start() {
        status = .inProgress
        startDate = Date()
    }
    
    mutating func complete() {
        status = .completed
        completedDate = Date()
        progress = 1.0
    }
    
    mutating func skip() {
        status = .skipped
    }
    
    mutating func updateProgress(_ newProgress: Double) {
        progress = min(max(newProgress, 0.0), 1.0)
        if progress >= 1.0 {
            complete()
        }
    }
}

// Predefined quests for the app
extension Quest {
    static let sampleQuests: [Quest] = [
        // Lifestyle Quests
        Quest(title: "Morning Hydration", description: "Drink a full glass of water immediately after waking up", category: .lifestyle, difficulty: .easy, estimatedDuration: 300, iconName: "drop.fill"),
        Quest(title: "Digital Sunset", description: "Turn off all screens 1 hour before bedtime", category: .lifestyle, difficulty: .medium, estimatedDuration: 3600, iconName: "moon.fill"),
        Quest(title: "Nature Walk", description: "Take a 20-minute walk in nature or a park", category: .lifestyle, difficulty: .easy, estimatedDuration: 1200, iconName: "leaf.fill"),
        
        // Productivity Quests
        Quest(title: "Inbox Zero", description: "Clear your email inbox completely", category: .productivity, difficulty: .medium, estimatedDuration: 1800, iconName: "envelope.fill"),
        Quest(title: "Deep Work Session", description: "Complete 90 minutes of focused work without distractions", category: .productivity, difficulty: .hard, estimatedDuration: 5400, iconName: "brain.head.profile"),
        Quest(title: "Task Prioritization", description: "Organize your to-do list using the Eisenhower Matrix", category: .productivity, difficulty: .easy, estimatedDuration: 900, iconName: "checklist"),
        
        // Mindfulness Quests
        Quest(title: "Gratitude Journal", description: "Write down 3 things you're grateful for today", category: .mindfulness, difficulty: .easy, estimatedDuration: 600, iconName: "heart.fill"),
        Quest(title: "Meditation Session", description: "Complete a 10-minute guided meditation", category: .mindfulness, difficulty: .medium, estimatedDuration: 600, iconName: "leaf.circle.fill"),
        Quest(title: "Breathing Exercise", description: "Practice 4-7-8 breathing technique for 5 minutes", category: .mindfulness, difficulty: .easy, estimatedDuration: 300, iconName: "lungs.fill"),
        
        // Fitness Quests
        Quest(title: "Morning Stretch", description: "Complete a 10-minute morning stretching routine", category: .fitness, difficulty: .easy, estimatedDuration: 600, iconName: "figure.flexibility"),
        Quest(title: "Stairs Challenge", description: "Take the stairs instead of elevator for the entire day", category: .fitness, difficulty: .medium, estimatedDuration: 86400, iconName: "figure.stairs"),
        
        // Learning Quests
        Quest(title: "New Word", description: "Learn and use a new word in conversation today", category: .learning, difficulty: .easy, estimatedDuration: 1800, iconName: "book.fill"),
        Quest(title: "Skill Practice", description: "Practice a skill or hobby for 30 minutes", category: .learning, difficulty: .medium, estimatedDuration: 1800, iconName: "graduationcap.fill"),
        
        // Creativity Quests
        Quest(title: "Photo Story", description: "Take 5 photos that tell a story about your day", category: .creativity, difficulty: .easy, estimatedDuration: 1800, iconName: "camera.fill"),
        Quest(title: "Creative Writing", description: "Write a short story or poem (100+ words)", category: .creativity, difficulty: .medium, estimatedDuration: 2700, iconName: "pencil.and.outline"),
        
        // Social Quests
        Quest(title: "Random Kindness", description: "Perform a random act of kindness for someone", category: .social, difficulty: .easy, estimatedDuration: 1800, iconName: "heart.circle.fill"),
        Quest(title: "Quality Connection", description: "Have a meaningful conversation with a friend or family member", category: .social, difficulty: .medium, estimatedDuration: 3600, iconName: "person.2.fill")
    ]
}

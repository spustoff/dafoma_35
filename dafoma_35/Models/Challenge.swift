//
//  Challenge.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation

enum ChallengeType: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case community = "Community"
}

enum ChallengeStatus: String, Codable {
    case upcoming = "Upcoming"
    case active = "Active"
    case completed = "Completed"
    case failed = "Failed"
}

struct Challenge: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: ChallengeType
    let category: QuestCategory
    let startDate: Date
    let endDate: Date
    let targetValue: Int // Target number of quests or points
    let iconName: String
    var status: ChallengeStatus
    var currentProgress: Int
    var participantCount: Int
    var reward: ChallengeReward
    
    init(title: String, description: String, type: ChallengeType, category: QuestCategory, startDate: Date, endDate: Date, targetValue: Int, iconName: String, reward: ChallengeReward) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.type = type
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.targetValue = targetValue
        self.iconName = iconName
        self.status = startDate > Date() ? .upcoming : .active
        self.currentProgress = 0
        self.participantCount = Int.random(in: 50...500)
        self.reward = reward
    }
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return Double(currentProgress) / Double(targetValue)
    }
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate && status == .active
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }
    
    mutating func updateProgress(_ newProgress: Int) {
        currentProgress = newProgress
        if currentProgress >= targetValue {
            status = .completed
        }
    }
}

struct ChallengeReward: Codable {
    let points: Int
    let badgeTitle: String
    let badgeIconName: String
}

// Sample challenges
extension Challenge {
    static let sampleChallenges: [Challenge] = [
        Challenge(
            title: "7-Day Mindfulness Journey",
            description: "Complete at least one mindfulness quest each day for a week",
            type: .weekly,
            category: .mindfulness,
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            targetValue: 7,
            iconName: "leaf.circle.fill",
            reward: ChallengeReward(points: 100, badgeTitle: "Mindful Master", badgeIconName: "brain.head.profile")
        ),
        Challenge(
            title: "Productivity Powerhouse",
            description: "Earn 200 points from productivity quests this month",
            type: .monthly,
            category: .productivity,
            startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date(),
            targetValue: 200,
            iconName: "bolt.fill",
            reward: ChallengeReward(points: 250, badgeTitle: "Productivity Pro", badgeIconName: "chart.line.uptrend.xyaxis")
        ),
        Challenge(
            title: "Daily Hydration Hero",
            description: "Complete the morning hydration quest for 30 days straight",
            type: .monthly,
            category: .lifestyle,
            startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
            targetValue: 30,
            iconName: "drop.fill",
            reward: ChallengeReward(points: 300, badgeTitle: "Hydration Hero", badgeIconName: "drop.circle.fill")
        ),
        Challenge(
            title: "Community Kindness",
            description: "Join 1000+ users in spreading kindness this week",
            type: .community,
            category: .social,
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
            targetValue: 3,
            iconName: "heart.circle.fill",
            reward: ChallengeReward(points: 150, badgeTitle: "Kindness Champion", badgeIconName: "heart.fill")
        )
    ]
}

//
//  DataService.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var user: User?
    @Published var availableQuests: [Quest] = []
    @Published var activeQuests: [Quest] = []
    @Published var completedQuests: [Quest] = []
    @Published var challenges: [Challenge] = []
    @Published var progressStats: ProgressStats = ProgressStats()
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "saved_user"
    private let questsKey = "saved_quests"
    private let challengesKey = "saved_challenges"
    private let progressKey = "saved_progress"
    
    init() {
        loadData()
        setupInitialData()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadUser()
        loadQuests()
        loadChallenges()
        loadProgress()
    }
    
    private func loadUser() {
        if let userData = userDefaults.data(forKey: userKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        }
    }
    
    private func loadQuests() {
        if let questsData = userDefaults.data(forKey: questsKey),
           let decodedQuests = try? JSONDecoder().decode([Quest].self, from: questsData) {
            categorizeQuests(decodedQuests)
        }
    }
    
    private func loadChallenges() {
        if let challengesData = userDefaults.data(forKey: challengesKey),
           let decodedChallenges = try? JSONDecoder().decode([Challenge].self, from: challengesData) {
            self.challenges = decodedChallenges
        }
    }
    
    private func loadProgress() {
        if let progressData = userDefaults.data(forKey: progressKey),
           let decodedProgress = try? JSONDecoder().decode(ProgressStats.self, from: progressData) {
            self.progressStats = decodedProgress
        }
    }
    
    func saveData() {
        saveUser()
        saveQuests()
        saveChallenges()
        saveProgress()
    }
    
    private func saveUser() {
        if let user = user,
           let encodedUser = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedUser, forKey: userKey)
        }
    }
    
    private func saveQuests() {
        let allQuests = availableQuests + activeQuests + completedQuests
        if let encodedQuests = try? JSONEncoder().encode(allQuests) {
            userDefaults.set(encodedQuests, forKey: questsKey)
        }
    }
    
    private func saveChallenges() {
        if let encodedChallenges = try? JSONEncoder().encode(challenges) {
            userDefaults.set(encodedChallenges, forKey: challengesKey)
        }
    }
    
    private func saveProgress() {
        if let encodedProgress = try? JSONEncoder().encode(progressStats) {
            userDefaults.set(encodedProgress, forKey: progressKey)
        }
    }
    
    // MARK: - Initial Setup
    
    private func setupInitialData() {
        if availableQuests.isEmpty && activeQuests.isEmpty && completedQuests.isEmpty {
            availableQuests = Quest.sampleQuests
            saveQuests()
        }
        
        if challenges.isEmpty {
            challenges = Challenge.sampleChallenges
            saveChallenges()
        }
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String) {
        let newUser = User(name: name, email: email)
        self.user = newUser
        saveUser()
    }
    
    func updateUser(_ updatedUser: User) {
        self.user = updatedUser
        saveUser()
    }
    
    // MARK: - Quest Management
    
    private func categorizeQuests(_ quests: [Quest]) {
        availableQuests = quests.filter { $0.status == .available }
        activeQuests = quests.filter { $0.status == .inProgress }
        completedQuests = quests.filter { $0.status == .completed }
    }
    
    func startQuest(_ quest: Quest) {
        guard let index = availableQuests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        availableQuests[index].start()
        let startedQuest = availableQuests.remove(at: index)
        activeQuests.append(startedQuest)
        
        saveQuests()
    }
    
    func completeQuest(_ quest: Quest) {
        guard let index = activeQuests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        activeQuests[index].complete()
        let completedQuest = activeQuests.remove(at: index)
        completedQuests.append(completedQuest)
        
        // Update progress
        progressStats.totalQuestsCompleted += 1
        progressStats.totalPointsEarned += completedQuest.points
        progressStats.updateLevel()
        
        // Update user stats
        if var currentUser = user {
            currentUser.totalQuestsCompleted += 1
            currentUser.totalPoints += completedQuest.points
            currentUser.level = progressStats.level
            updateUser(currentUser)
        }
        
        // Update challenges progress
        updateChallengeProgress(for: completedQuest)
        
        saveData()
    }
    
    func skipQuest(_ quest: Quest) {
        guard let index = activeQuests.firstIndex(where: { $0.id == quest.id }) else { return }
        
        activeQuests[index].skip()
        let skippedQuest = activeQuests.remove(at: index)
        availableQuests.append(skippedQuest)
        
        saveQuests()
    }
    
    func updateQuestProgress(_ quest: Quest, progress: Double) {
        if let index = activeQuests.firstIndex(where: { $0.id == quest.id }) {
            activeQuests[index].updateProgress(progress)
            if activeQuests[index].status == .completed {
                completeQuest(activeQuests[index])
            } else {
                saveQuests()
            }
        }
    }
    
    // MARK: - Challenge Management
    
    private func updateChallengeProgress(for quest: Quest) {
        for i in 0..<challenges.count {
            if challenges[i].category == quest.category && challenges[i].isActive {
                challenges[i].updateProgress(challenges[i].currentProgress + 1)
            }
        }
        saveChallenges()
    }
    
    func joinChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].participantCount += 1
            saveChallenges()
        }
    }
    
    // MARK: - Daily Quest Refresh
    
    func refreshDailyQuests() {
        // Move completed quests back to available (for daily refresh)
        let questsToRefresh = completedQuests.filter { quest in
            guard let completedDate = quest.completedDate else { return false }
            let calendar = Calendar.current
            return !calendar.isDateInToday(completedDate)
        }
        
        for quest in questsToRefresh {
            if let index = completedQuests.firstIndex(where: { $0.id == quest.id }) {
                var refreshedQuest = completedQuests.remove(at: index)
                refreshedQuest.status = .available
                refreshedQuest.startDate = nil
                refreshedQuest.completedDate = nil
                refreshedQuest.progress = 0.0
                availableQuests.append(refreshedQuest)
            }
        }
        
        saveQuests()
    }
    
    // MARK: - Analytics
    
    func getQuestsCompletedThisWeek() -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return completedQuests.filter { quest in
            guard let completedDate = quest.completedDate else { return false }
            return completedDate >= startOfWeek
        }.count
    }
    
    func getQuestsCompletedToday() -> Int {
        let calendar = Calendar.current
        return completedQuests.filter { quest in
            guard let completedDate = quest.completedDate else { return false }
            return calendar.isDateInToday(completedDate)
        }.count
    }
    
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        // Check if user completed any quests today
        let todayCompleted = completedQuests.contains { quest in
            guard let completedDate = quest.completedDate else { return false }
            return calendar.isDateInToday(completedDate)
        }
        
        if todayCompleted {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        // Check previous days
        while true {
            let dayCompleted = completedQuests.contains { quest in
                guard let completedDate = quest.completedDate else { return false }
                return calendar.isDate(completedDate, inSameDayAs: currentDate)
            }
            
            if dayCompleted {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Reset Data
    
    func resetAllData() {
        // Reset all published properties
        user = nil
        availableQuests = Quest.sampleQuests
        activeQuests = []
        completedQuests = []
        challenges = Challenge.sampleChallenges
        progressStats = ProgressStats()
        
        // Clear all UserDefaults
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: questsKey)
        userDefaults.removeObject(forKey: challengesKey)
        userDefaults.removeObject(forKey: progressKey)
    }
}

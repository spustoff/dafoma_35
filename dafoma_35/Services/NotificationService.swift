//
//  NotificationService.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation
import UserNotifications
import Combine

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var permissionGranted = false
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
        checkPermissionStatus()
    }
    
    // MARK: - Permission Management
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func checkPermissionStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Mindful Break Notifications
    
    func scheduleMindfulBreakNotifications(interval: TimeInterval = 3600) {
        guard permissionGranted else { return }
        
        // Remove existing mindful break notifications
        center.removePendingNotificationRequests(withIdentifiers: ["mindful_break"])
        
        let content = UNMutableNotificationContent()
        content.title = "Time for a Mindful Break"
        content.body = "Take a moment to breathe and reset your mind"
        content.sound = .default
        content.categoryIdentifier = "MINDFUL_BREAK"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "mindful_break", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling mindful break notification: \(error)")
            }
        }
    }
    
    // MARK: - Daily Quest Reminders
    
    func scheduleDailyQuestReminder() {
        guard permissionGranted else { return }
        
        // Remove existing daily quest reminders
        center.removePendingNotificationRequests(withIdentifiers: ["daily_quest_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Quest Awaits!"
        content.body = "Start your day with purpose - check out today's quests"
        content.sound = .default
        content.categoryIdentifier = "DAILY_QUEST"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_quest_reminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily quest reminder: \(error)")
            }
        }
    }
    
    // MARK: - Quest Completion Celebration
    
    func scheduleQuestCompletionCelebration(questTitle: String) {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Quest Completed! 🎉"
        content.body = "Great job completing '\(questTitle)'! Keep up the momentum!"
        content.sound = .default
        content.categoryIdentifier = "QUEST_COMPLETED"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "quest_completed_\(UUID().uuidString)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling quest completion notification: \(error)")
            }
        }
    }
    
    // MARK: - Streak Reminders
    
    func scheduleStreakReminder(currentStreak: Int) {
        guard permissionGranted else { return }
        
        // Remove existing streak reminders
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You're on a \(currentStreak)-day streak! Complete a quest to keep it going"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error)")
            }
        }
    }
    
    // MARK: - Challenge Notifications
    
    func scheduleChallengeReminder(challengeTitle: String, daysRemaining: Int) {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Challenge Update"
        content.body = "\(challengeTitle) ends in \(daysRemaining) days! Keep pushing forward!"
        content.sound = .default
        content.categoryIdentifier = "CHALLENGE_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "challenge_reminder_\(UUID().uuidString)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling challenge reminder: \(error)")
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func removeNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Breathing Exercise Notifications
    
    func scheduleBreathingExerciseReminder() {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Breathe & Reset"
        content.body = "Take 2 minutes for a breathing exercise to center yourself"
        content.sound = .default
        content.categoryIdentifier = "BREATHING_EXERCISE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true) // Every 2 hours
        let request = UNNotificationRequest(identifier: "breathing_exercise", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling breathing exercise reminder: \(error)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        // Handle notification taps
        switch categoryIdentifier {
        case "MINDFUL_BREAK":
            // Navigate to mindful breaks section
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToMindfulBreaks"), object: nil)
        case "DAILY_QUEST":
            // Navigate to quests section
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToQuests"), object: nil)
        case "QUEST_COMPLETED":
            // Navigate to progress section
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToProgress"), object: nil)
        case "STREAK_REMINDER":
            // Navigate to main screen
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToHome"), object: nil)
        case "CHALLENGE_REMINDER":
            // Navigate to challenges section
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToChallenges"), object: nil)
        case "BREATHING_EXERCISE":
            // Navigate to breathing exercises
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToBreathing"), object: nil)
        default:
            break
        }
        
        completionHandler()
    }
}

//
//  ColorExtension.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import SwiftUI

extension Color {
    // App Color Scheme
    static let appBackground = Color(hex: "0d1017")
    static let appPrimary = Color(hex: "ff2300")
    static let appSecondary = Color(hex: "06dbab")
    
    // Additional colors for better UI
    static let cardBackground = Color(hex: "1a1f2e")
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let successGreen = Color.green
    static let warningYellow = Color.yellow
    static let dangerRed = Color.red
    
    // Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Colors
extension Color {
    static func categoryColor(for category: QuestCategory) -> Color {
        switch category {
        case .lifestyle:
            return Color.appSecondary
        case .productivity:
            return Color.appPrimary
        case .mindfulness:
            return Color.purple
        case .fitness:
            return Color.orange
        case .learning:
            return Color.blue
        case .creativity:
            return Color.pink
        case .social:
            return Color.green
        }
    }
}

// MARK: - Difficulty Colors
extension Color {
    static func difficultyColor(for difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return Color.green
        case .medium:
            return Color.orange
        case .hard:
            return Color.red
        }
    }
}

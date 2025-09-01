//
//  DateExtension.swift
//  dafoma_35
//
//  Created by AI Assistant
//

import Foundation

extension Date {
    // Format date for display
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    // Format time for display
    func timeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // Get relative time string (e.g., "2 hours ago")
    func relativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    // Check if date is this week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    // Get start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    // Get end of day
    var endOfDay: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }
    
    // Get start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }
    
    // Get end of week
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .weekOfYear, for: self)?.end ?? self
    }
    
    // Get days between dates
    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        return components.day ?? 0
    }
    
    // Get week number in year
    var weekOfYear: Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: self)
    }
    
    // Get month name
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    // Get day name
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    // Get short day name
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    // Convert seconds to readable duration string
    func durationString() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // Convert seconds to human readable format
    func humanReadableDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
    
    // Convert to minutes
    var minutes: Int {
        return Int(self) / 60
    }
    
    // Convert to hours
    var hours: Double {
        return self / 3600
    }
}

//
//  SimpleMainView.swift
//  dafoma_35
//
//  Created by AI Assistant - Simplified version for iOS 15.6 compatibility
//

import SwiftUI

struct SimpleMainView: View {
    @StateObject private var dataService = DataService.shared
    @State private var selectedTab = 0
    @Binding var isOnboardingComplete: Bool
    
    init(isOnboardingComplete: Binding<Bool>) {
        self._isOnboardingComplete = isOnboardingComplete
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SimpleHomeView(isOnboardingComplete: $isOnboardingComplete)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SimpleQuestsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Quests")
                }
                .tag(1)
            
            SimpleMindfulView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Mindful")
                }
                .tag(2)
            
            SimpleProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(3)
            
            SimpleSettingsView(isOnboardingComplete: $isOnboardingComplete)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(Color.appPrimary)
    }
}

struct SimpleHomeView: View {
    @EnvironmentObject var dataService: DataService
    @State private var showingSettings = false
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("DayQuest Pin")
                                        .font(.largeTitle.weight(.bold))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text("Transform your day with meaningful quests")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gear")
                                        .font(.title2)
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats
                        HStack(spacing: 15) {
                            SimpleStatCard(
                                title: "Completed",
                                value: "\(dataService.progressStats.totalQuestsCompleted)",
                                color: .appPrimary
                            )
                            
                            SimpleStatCard(
                                title: "Points",
                                value: "\(dataService.progressStats.totalPointsEarned)",
                                color: .appSecondary
                            )
                            
                            SimpleStatCard(
                                title: "Level",
                                value: "\(dataService.progressStats.level)",
                                color: .purple
                            )
                        }
                        
                        // Active quests
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Active Quests")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            if dataService.activeQuests.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "target")
                                        .font(.largeTitle)
                                        .foregroundColor(.textSecondary)
                                    
                                    Text("No active quests")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    
                                    Text("Start a quest to begin your journey!")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(dataService.activeQuests.prefix(3), id: \.id) { quest in
                                        SimpleQuestRow(quest: quest)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SimpleSettingsView(isOnboardingComplete: $isOnboardingComplete)
        }
    }
}

struct SimpleQuestsView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedQuest: Quest?
    @State private var showingAlert = false
    @State private var alertType: AlertType = .start
    
    enum AlertType {
        case start, complete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Daily Quests")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.textPrimary)
                            .padding(.top, 20)
                        
                        // Available quests
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Available Quests")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(dataService.availableQuests, id: \.id) { quest in
                                    SimpleQuestCard(quest: quest) {
                                        selectedQuest = quest
                                        alertType = .start
                                        showingAlert = true
                                    }
                                }
                            }
                        }
                        
                        // Active quests
                        if !dataService.activeQuests.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Active Quests")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(dataService.activeQuests, id: \.id) { quest in
                                        SimpleActiveQuestCard(quest: quest) {
                                            selectedQuest = quest
                                            alertType = .complete
                                            showingAlert = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingAlert) {
            if alertType == .start {
                return Alert(
                    title: Text("Start Quest"),
                    message: Text("Ready to begin '\(selectedQuest?.title ?? "")'?"),
                    primaryButton: .default(Text("Start")) {
                        if let quest = selectedQuest {
                            dataService.startQuest(quest)
                        }
                    },
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(
                    title: Text("Complete Quest"),
                    message: Text("Mark '\(selectedQuest?.title ?? "")' as completed?"),
                    primaryButton: .default(Text("Complete")) {
                        if let quest = selectedQuest {
                            dataService.completeQuest(quest)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct SimpleMindfulView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Mindful Breaks")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.textPrimary)
                        .padding(.top, 20)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.appSecondary)
                    
                    VStack(spacing: 15) {
                        Text("Take a moment to breathe")
                            .font(.title2)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("\"The present moment is the only time over which we have dominion.\"")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Text("- Thich Nhat Hanh")
                            .font(.caption)
                            .foregroundColor(.appSecondary)
                    }
                    
                    VStack(spacing: 15) {
                        SimpleMindfulButton(
                            title: "4-7-8 Breathing",
                            subtitle: "1 minute exercise",
                            icon: "lungs.fill",
                            color: .appSecondary
                        )
                        
                        SimpleMindfulButton(
                            title: "Body Scan",
                            subtitle: "2 minute relaxation",
                            icon: "figure.mind.and.body",
                            color: .purple
                        )
                        
                        SimpleMindfulButton(
                            title: "Gratitude Moment",
                            subtitle: "1 minute reflection",
                            icon: "heart.fill",
                            color: .pink
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SimpleProgressView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Your Progress")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.textPrimary)
                            .padding(.top, 20)
                        
                        // Level progress
                        VStack(spacing: 15) {
                            Text("Level \(dataService.progressStats.level)")
                                .font(.title.weight(.bold))
                                .foregroundColor(.appSecondary)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Experience")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text("\(dataService.progressStats.experiencePoints)/100 XP")
                                        .font(.subheadline)
                                        .foregroundColor(.textPrimary)
                                }
                                
                                SimpleProgressBar(progress: Double(dataService.progressStats.experiencePoints) / 100.0)
                                    .frame(height: 8)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        // Stats grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            SimpleProgressCard(
                                title: "Total Quests",
                                value: "\(dataService.progressStats.totalQuestsCompleted)",
                                icon: "target",
                                color: .appPrimary
                            )
                            
                            SimpleProgressCard(
                                title: "Total Points",
                                value: "\(dataService.progressStats.totalPointsEarned)",
                                icon: "star.fill",
                                color: .appSecondary
                            )
                            
                            SimpleProgressCard(
                                title: "Current Streak",
                                value: "\(dataService.getCurrentStreak())",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            SimpleProgressCard(
                                title: "Best Streak",
                                value: "\(dataService.progressStats.longestStreak)",
                                icon: "trophy.fill",
                                color: .purple
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Simple Components

struct SimpleStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct SimpleQuestRow: View {
    let quest: Quest
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.iconName)
                .font(.title3)
                .foregroundColor(Color.categoryColor(for: quest.category))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textPrimary)
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(quest.points)pts")
                .font(.caption.weight(.bold))
                .foregroundColor(.appSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct SimpleQuestCard: View {
    let quest: Quest
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(quest.category.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.categoryColor(for: quest.category))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text("\(quest.points) pts")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.appSecondary)
                }
                
                Text(quest.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(quest.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(quest.estimatedDuration.humanReadableDuration())
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("Start Quest")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.appPrimary)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimpleActiveQuestCard: View {
    let quest: Quest
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(quest.category.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.categoryColor(for: quest.category))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 6, height: 6)
                        
                        Text("Active")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.appPrimary)
                    }
                }
                
                Text(quest.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(quest.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                if quest.progress > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            Text("\(Int(quest.progress * 100))%")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.textPrimary)
                        }
                        
                        SimpleProgressBar(progress: quest.progress)
                            .frame(height: 4)
                    }
                }
                
                HStack {
                    Text("\(quest.points) points")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("Complete Quest")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.successGreen)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appPrimary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimpleMindfulButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct SimpleProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct SimpleProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
        .cornerRadius(4)
    }
}

#Preview {
    SimpleMainView(isOnboardingComplete: .constant(true))
        .environmentObject(DataService.shared)
}

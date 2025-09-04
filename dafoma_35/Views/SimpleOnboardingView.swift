//
//  SimpleOnboardingView.swift
//  dafoma_35
//
//  Created by AI Assistant - Simplified for iOS 15.6
//

import SwiftUI

struct SimpleOnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage = 0
    @State private var name = ""
    @State private var email = ""
    
    private var isNextButtonEnabled: Bool {
        switch currentPage {
        case 0, 2: // Welcome and completion pages - always enabled
            return true
        case 1: // Info page - require name and email
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                   !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   email.contains("@") && email.contains(".")
        default:
            return true
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                infoPage.tag(1)
                completePage.tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                Spacer()
                
                HStack {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.appPrimary : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: nextPage) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(isNextButtonEnabled ? Color.appPrimary : Color.gray)
                            .cornerRadius(22)
                    }
                    .disabled(!isNextButtonEnabled)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.appSecondary)
                
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.textSecondary)
                
                Text("DayQuest Pin")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.textPrimary)
            }
            
            Text("Transform your daily routine into meaningful adventures")
                .font(.title3)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
    
    private var infoPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Let's get to know you")
                .font(.title2.weight(.bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Name")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    TextField("Enter your name", text: $name)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .foregroundColor(.textPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !name.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .foregroundColor(.textPrimary)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((!email.contains("@") || !email.contains(".")) && !email.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if !email.isEmpty && (!email.contains("@") || !email.contains(".")) {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if currentPage == 1 && (!isNextButtonEnabled) {
                    Text("Please fill in all required fields to continue")
                        .font(.caption)
                        .foregroundColor(.appSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
    }
    
    private var completePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.successGreen)
                
                Text("You're all set!")
                    .font(.title.weight(.bold))
                    .foregroundColor(.textPrimary)
                
                Text("Ready to start your quest journey?")
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 15) {
                Text("✓ Personalized daily quests")
                    .font(.subheadline)
                    .foregroundColor(.appSecondary)
                
                Text("✓ Mindful break reminders")
                    .font(.subheadline)
                    .foregroundColor(.appSecondary)
                
                Text("✓ Progress tracking")
                    .font(.subheadline)
                    .foregroundColor(.appSecondary)
                
                Text("✓ Community challenges")
                    .font(.subheadline)
                    .foregroundColor(.appSecondary)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private func nextPage() {
        if currentPage < 2 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty && 
              !trimmedEmail.isEmpty && 
              trimmedEmail.contains("@") && 
              trimmedEmail.contains(".") else { 
            return 
        }
        
        // Save user info
        UserDefaults.standard.set(trimmedName, forKey: "user_name")
        UserDefaults.standard.set(trimmedEmail, forKey: "user_email")
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
        
        // Create user in data service
        DataService.shared.createUser(name: trimmedName, email: trimmedEmail)
        
        isComplete = true
    }
}

#Preview {
    SimpleOnboardingView(isComplete: .constant(false))
}

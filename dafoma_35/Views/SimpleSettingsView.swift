//
//  SimpleSettingsView.swift
//  dafoma_35
//
//  Created by AI Assistant - Simple settings for iOS 15.6
//

import SwiftUI

struct SimpleSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isOnboardingComplete: Bool
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "gear")
                                .font(.system(size: 60))
                                .foregroundColor(.appPrimary)
                            
                            Text("Settings")
                                .font(.largeTitle.weight(.bold))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.top, 20)
                        
                        // User info section
                        userInfoSection
                        
                        // Account management
                        accountSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Reset Account"),
                message: Text("This will reset all your progress and return you to the welcome screen. Are you sure?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingsInfoRow(
                    title: "Name",
                    value: UserDefaults.standard.string(forKey: "user_name") ?? "Not set",
                    icon: "person.fill"
                )
                
                SettingsInfoRow(
                    title: "Email",
                    value: UserDefaults.standard.string(forKey: "user_email") ?? "Not set",
                    icon: "envelope.fill"
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("App Settings")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingsToggleRow(
                    title: "Notifications",
                    description: "Receive quest reminders",
                    icon: "bell.fill",
                    isOn: .constant(true)
                )
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                SettingsToggleRow(
                    title: "Dark Mode",
                    description: "Always enabled for better focus",
                    icon: "moon.fill",
                    isOn: .constant(true)
                )
                .disabled(true)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account Management")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 10) {
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                SettingsActionRow(
                    title: "Reset Account",
                    description: "Clear all data and return to welcome screen",
                    icon: "trash.fill",
                    color: .red
                ) {
                    showingDeleteConfirmation = true
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 10) {
                SettingsActionRow(
                    title: "About DayQuest Pin",
                    description: "Version 1.0",
                    icon: "info.circle.fill",
                    color: .appSecondary
                ) {
                    // TODO: Show about page
                }
                
                SettingsActionRow(
                    title: "Privacy Policy",
                    description: "How we protect your data",
                    icon: "hand.raised.fill",
                    color: .green
                ) {
                    // TODO: Show privacy policy
                }
                
                SettingsActionRow(
                    title: "Contact Support",
                    description: "Get help or send feedback",
                    icon: "envelope.fill",
                    color: .purple
                ) {
                    // TODO: Contact support
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func resetAccount() {
        // Clear all UserDefaults data
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "onboarding_complete")
        UserDefaults.standard.removeObject(forKey: "saved_user")
        UserDefaults.standard.removeObject(forKey: "saved_quests")
        UserDefaults.standard.removeObject(forKey: "saved_challenges")
        UserDefaults.standard.removeObject(forKey: "saved_progress")
        
        // Reset DataService
        DataService.shared.resetAllData()
        
        // Return to onboarding
        isOnboardingComplete = false
        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textPrimary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.appPrimary)
        }
    }
}

struct SettingsActionRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SimpleSettingsView(isOnboardingComplete: .constant(true))
}

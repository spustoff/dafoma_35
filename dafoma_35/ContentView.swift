//
//  ContentView.swift
//  dafoma_35
//
//  Created by Вячеслав on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
    
    var body: some View {
        Group {
            if isOnboardingComplete {
                SimpleMainView()
                    .environmentObject(DataService.shared)
            } else {
                SimpleOnboardingView(isComplete: $isOnboardingComplete)
            }
        }
        .animation(.easeInOut, value: isOnboardingComplete)
    }
}

#Preview {
    ContentView()
}

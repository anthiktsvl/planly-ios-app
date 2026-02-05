//
//  ContentView.swift
//  Planly
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataViewModel: AppDataViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .task {
            if authViewModel.isAuthenticated {
                await dataViewModel.loadAllData()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
}

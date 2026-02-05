//
//  PlanlyApp.swift
//  Planly
//

import SwiftUI

@main
struct PlanlyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataViewModel = AppDataViewModel()
    
    init() {
        print("🚨🚨🚨 APP LAUNCHED! 🚨🚨🚨")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(dataViewModel)
                .onAppear {
                    print("🚨 ContentView appeared!")
                }
        }
    }
}

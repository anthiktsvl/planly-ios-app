//
//  planlyApp.swift
//  planly
//
//  Created by Anthi Kouts on 5/5/26.
//

import SwiftUI

@main
struct planlyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataViewModel = AppDataViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var fontManager = FontManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
                .environmentObject(dataViewModel)
                .environmentObject(themeManager)
                .environmentObject(fontManager)
        }
    }
}

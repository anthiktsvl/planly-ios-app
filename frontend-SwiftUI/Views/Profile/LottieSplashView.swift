//
//  LottieSplashView.swift
//  Planly
//
//  Root view that initializes all StateObjects and provides them to the app

import SwiftUI

struct LottieSplashView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataViewModel = AppDataViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var fontManager = FontManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        ContentView()
            .environmentObject(authViewModel)
            .environmentObject(dataViewModel)
            .environmentObject(themeManager)
            .environmentObject(fontManager)
            .environmentObject(notificationManager)
            .onAppear {
                // Connect the notification manager to the data view model
                dataViewModel.notificationManager = notificationManager
            }
    }
}

#Preview {
    LottieSplashView()
}

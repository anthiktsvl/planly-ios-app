//
//  ContentView.swift
//  Planly
//

/* Root routing view for the app. Keeps the “signed in vs signed out” decision in one place so the rest of the UI doesn’t have to constantly check auth state.
*/

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    
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
/*Preview uses fresh mock instances so the view can render in Xcode without the app.*/
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}

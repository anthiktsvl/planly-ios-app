//
//  ContentView.swift
//  planly
//
//  Created by Anthi Kouts on 5/5/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    
    var body: some View {
        MainTabView()
    }
}
#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}


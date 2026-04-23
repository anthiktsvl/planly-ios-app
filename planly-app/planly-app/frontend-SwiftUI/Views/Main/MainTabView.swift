//
//  MainTabView.swift
//  Planly
//

import SwiftUI

struct MainTabView: View {
    
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        TabView {
            HomeView()
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle.fill")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(ColorTheme.babyPinkDark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
}

//
//  ProfileView.swift
//  Planly
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    
    var userName: String {
        authViewModel.currentUser?.name ?? "User"
    }
    
    var userEmail: String {
        authViewModel.currentUser?.email ?? "email@example.com"
    }
    
    var completionRate: Double {
        let total = dataViewModel.tasks.count
        if total == 0 { return 0 }
        let completed = dataViewModel.completedTasks.count
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                AnimatedProfileBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Profile Header Card
                        ProfileHeaderCard(
                            userName: userName,
                            userEmail: userEmail,
                            completionRate: completionRate,
                            showingEditProfile: $showingEditProfile
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        
                        // Stats Grid
                        StatsGridView(dataViewModel: dataViewModel)
                            .padding(.horizontal, 12)
                        
                        // Quick Actions
                        QuickActionsSection()
                            .padding(.horizontal, 12)
                        
                        // Settings Sections
                        SettingsSections(
                            showingSettings: $showingSettings,
                            showingLogoutAlert: $showingLogoutAlert
                        )
                        .padding(.horizontal, 12)
                        
                        // App Info
                        AppInfoSection()
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                AdvancedSettingsView()
            }
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedProfileBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ColorTheme.babyPink.opacity(0.15), .clear],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? 100 : 150, y: -200)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ColorTheme.babyPinkDark.opacity(0.15), .clear],
                        center: .bottomLeading,
                        startRadius: 0,
                        endRadius: 500
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? -100 : -150, y: 300)
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Profile Header Card
struct ProfileHeaderCard: View {
    let userName: String
    let userEmail: String
    let completionRate: Double
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Picture & Name
            VStack(spacing: 10) {
                ZStack {
                    // Animated ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.babyPink.opacity(0.3), ColorTheme.babyPinkLight.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 95, height: 95)
                    
                    // Profile circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                    
                    // Initials
                    Text(getInitials(from: userName))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 3) {
                    Text(userName)
                        .font(.body)
                        .fontWeight(.bold)
                    
                    Text(userEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Edit Button
                Button {
                    showingEditProfile = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.caption2)
                        Text("Edit Profile")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // Completion Rate
            VStack(spacing: 8) {
                Text("Overall Completion Rate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 75, height: 75)
                    
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 75, height: 75)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.5, dampingFraction: 0.7), value: completionRate)
                    
                    VStack(spacing: 1) {
                        Text("\(Int(completionRate * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Done")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }
}

// MARK: - Stats Grid
struct StatsGridView: View {
    @ObservedObject var dataViewModel: AppDataViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Tasks",
                    value: "\(dataViewModel.tasks.count)",
                    color: .pink
                )
                
                StatCard(
                    icon: "folder.fill",
                    title: "Projects",
                    value: "\(dataViewModel.projects.count)",
                    color: .purple
                )
            }
            
            HStack(spacing: 8) {
                StatCard(
                    icon: "video.fill",
                    title: "Meetings",
                    value: "\(dataViewModel.meetings.count)",
                    color: .blue
                )
                
                StatCard(
                    icon: "calendar",
                    title: "This Week",
                    value: "\(dataViewModel.incompleteTasks.count)",
                    color: .green
                )
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Quick Actions
struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 10) {
                QuickActionButton(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    subtitle: "Manage your alerts",
                    color: .orange
                )
                
                QuickActionButton(
                    icon: "moon.fill",
                    title: "Focus Mode",
                    subtitle: "Minimize distractions",
                    color: .indigo
                )
                
                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Analytics",
                    subtitle: "Track your productivity",
                    color: .green
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button {
            // Action
        } label: {
            HStack(spacing: 14) {
                // ICON - BIGGER AND MORE VISIBLE
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
}

// MARK: - Settings Sections
struct SettingsSections: View {
    @Binding var showingSettings: Bool
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "gear",
                    title: "Preferences",
                    color: .gray
                ) {
                    showingSettings = true
                }
                
                Divider()
                    .padding(.leading, 64)
                
                SettingsRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    color: .blue
                ) {
                    // Action
                }
                
                Divider()
                    .padding(.leading, 64)
                
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    color: .green
                ) {
                    // Action
                }
                
                Divider()
                    .padding(.leading, 64)
                
                SettingsRow(
                    icon: "arrow.right.circle.fill",
                    title: "Sign Out",
                    color: .red
                ) {
                    showingLogoutAlert = true
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // ICON - BIGGER AND MORE VISIBLE
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
        }
    }
}

// MARK: - App Info
struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.body)
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Planly")
                .font(.caption)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("Made with ❤️")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Picture
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                
                                Text(getInitials(from: name.isEmpty ? "User" : name))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Button("Change Photo") {
                                // Action
                            }
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .padding(.top, 16)
                        
                        // Form
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Name", systemImage: "person.fill")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                TextField("Your name", text: $name)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Email", systemImage: "envelope.fill")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                TextField("your.email@example.com", text: $email)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Save Button
                        Button {
                            saveChanges()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [ColorTheme.babyPink, ColorTheme.babyPinkDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: .pink.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    name = user.name
                    email = user.email
                }
            }
        }
    }
    
    func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }
    
    func saveChanges() {
        // TODO: Implement API call to update user
        dismiss()
    }
}

// MARK: - Advanced Settings View
struct AdvancedSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var emailUpdates = false
    @State private var darkModeEnabled = false
    @State private var workStartTime = Date()
    @State private var workEndTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                        .tint(.pink)
                    Toggle("Email Updates", isOn: $emailUpdates)
                        .tint(.pink)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .tint(.purple)
                }
                
                Section("Work Hours") {
                    DatePicker("Start Time", selection: $workStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $workEndTime, displayedComponents: .hourAndMinute)
                }
                
                Section("Data") {
                    Button("Export Data") {
                        // Action
                    }
                    
                    Button("Clear Cache") {
                        // Action
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        // Action
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
}

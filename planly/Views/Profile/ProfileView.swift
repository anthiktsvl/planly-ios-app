//
//  ProfileView.swift
//  Planly
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    @State private var quickActionRoute: QuickActionRoute?
    @State private var showingNotifications = false
    @State private var showingFocusMode = false
    @State private var showingAnalytics = false
    @State private var showingPrivacySecurity = false
    @State private var showingHelpSupport = false
    @State private var showingThemeSettings = false
    @State private var showingFontSettings = false
    
    enum QuickActionRoute: Hashable {
        case notifications
        case focusMode
        case analytics
    }

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
                // Background should not intercept scroll/taps
                AnimatedProfileBackground()
                    .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ProfileHeaderCard(
                            userName: userName,
                            userEmail: userEmail,
                            completionRate: completionRate,
                            showingEditProfile: $showingEditProfile
                        )
                        .padding(.top, 14)

                        StatsGridView(dataViewModel: dataViewModel)

                        QuickActionsSection(
                            openNotifications: { showingNotifications = true },
                            openFocusMode: { showingFocusMode = true },
                            openAnalytics: { showingAnalytics = true },
                            onTapAnalytics: { showingAnalytics = true }
                        )

                        SettingsSections(
                            showingSettings: $showingSettings,
                                showingPrivacySecurity: $showingPrivacySecurity,
                                showingHelpSupport: $showingHelpSupport,
                                showingLogoutAlert: $showingLogoutAlert,
                                showingThemeSettings: $showingThemeSettings,
                                showingFontSettings: $showingFontSettings
                        )

                        AppInfoSection()
                            .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 60)
                }
                // Keep content above the tab bar safely on all devices
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                AdvancedSettingsView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingsView()
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingFontSettings) {
                FontSettingsView()
                    .environmentObject(fontManager)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsView()
                    .environmentObject(dataViewModel)
            }
            .sheet(isPresented: $showingPrivacySecurity) {
                PrivacySecurityView()
            }

            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
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
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [ColorTheme.primary(for: themeManager.currentTheme).opacity(0.15), .clear],
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
                        colors: [ColorTheme.dark(for: themeManager.currentTheme).opacity(0.15), .clear],
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
    @EnvironmentObject var themeManager: ThemeManager
    let userName: String
    let userEmail: String
    let completionRate: Double
    @Binding var showingEditProfile: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Profile Picture & Name
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3), ColorTheme.light(for: themeManager.currentTheme).opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 95, height: 95)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)

                    Text(getInitials(from: userName))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 3) {
                    Text(userName)
                        .adaptiveFont(.body, weight: .bold)

                    Text(userEmail)
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                }

                Button {
                    showingEditProfile = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.caption2)
                        Text("Edit Profile")
                            .adaptiveFont(.caption, weight: .semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
            }

            Divider()
                .padding(.vertical, 2)

            VStack(spacing: 8) {
                Text("Overall Completion Rate")
                    .adaptiveFont(.caption)
                    .foregroundColor(.secondary)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 75, height: 75)

                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
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
                            .adaptiveFont(.headline, weight: .bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Done")
                            .adaptiveFont(.caption2)
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
                    .adaptiveFont(.headline, weight: .bold)
                    .foregroundColor(color)

                Text(title)
                    .adaptiveFont(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Quick Actions
struct QuickActionsSection: View {
    let openNotifications: () -> Void
    let openFocusMode: () -> Void
    let openAnalytics: () -> Void
    let onTapAnalytics: () -> Void
    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick Actions")
                    .adaptiveFont(.subheadline, weight: .semibold)
                    .foregroundColor(.secondary)

                VStack(spacing: 10) {
                    QuickActionButton(
                        icon: "bell.badge.fill",
                        title: "Notifications",
                        subtitle: "Manage your alerts",
                        color: .orange
                    ) {
                        // (optional) hook later
                    }

                    QuickActionButton(
                        icon: "moon.fill",
                        title: "Focus Mode",
                        subtitle: "Minimize distractions",
                        color: .indigo
                    ) {
                        // (optional) hook later
                    }

                    QuickActionButton(
                        icon: "chart.bar.fill",
                        title: "View Analytics",
                        subtitle: "Track your productivity",
                        color: .green
                    ) {
                        onTapAnalytics()
                    }
                }
            }
        }
    }
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
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
                        .adaptiveFont(.subheadline, weight: .semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    
    }
}

// MARK: - Settings Sections
struct SettingsSections: View {
    @Binding var showingSettings: Bool
        @Binding var showingPrivacySecurity: Bool
        @Binding var showingHelpSupport: Bool
        @Binding var showingLogoutAlert: Bool
    @Binding var showingThemeSettings: Bool
    @Binding var showingFontSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .adaptiveFont(.subheadline, weight: .bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "paintpalette.fill",
                    title: "Color Theme",
                    color: .pink
                ) {
                    showingThemeSettings = true
                }

                Divider()
                    .padding(.leading, 64)

                SettingsRow(
                    icon: "textformat.size",
                    title: "Font Settings",
                    color: .orange
                ) {
                    showingFontSettings = true
                }

                Divider()
                    .padding(.leading, 64)

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
                    showingPrivacySecurity = true
                }

                Divider()
                    .padding(.leading, 64)

                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    color: .green
                ) {
                    showingHelpSupport = true
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
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                Text(title)
                    .adaptiveFont(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - App Info
struct AppInfoSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.body)
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Planly")
                .adaptiveFont(.caption, weight: .bold)

            Text("Version 1.0.0")
                .adaptiveFont(.caption2)
                .foregroundColor(.secondary)

            Text("Made with ❤️")
                .adaptiveFont(.caption2)
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
    @EnvironmentObject var themeManager: ThemeManager

    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
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
                                    colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .padding(.top, 16)

                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Name", systemImage: "person.fill")
                                    .adaptiveFont(.caption, weight: .semibold)
                                    .foregroundColor(.secondary)

                                TextField("Your name", text: $name)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Label("Email", systemImage: "envelope.fill")
                                    .adaptiveFont(.caption, weight: .semibold)
                                    .foregroundColor(.secondary)

                                TextField("your.email@example.com", text: $email)
                                    .disabled(true)
                                    .opacity(0.6)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                        Button {
                            Task { await saveChanges() }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Changes")
                                    .adaptiveFont(.subheadline, weight: .semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3), radius: 12, x: 0, y: 6)
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

    func saveChanges() async {
        guard let user = authViewModel.currentUser else { return }

        await authViewModel.updateProfile(
            name: name,
            workStartTime: user.workStartTime,
            workEndTime: user.workEndTime,
            timezone: user.timezone ?? TimeZone.current.identifier,
            notificationsEnabled: user.notificationsEnabled ?? true
        )

        if authViewModel.errorMessage == nil {
            dismiss()
        }
    }
}

// MARK: - Advanced Settings View
struct AdvancedSettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @Environment(\.dismiss) var dismiss
        @EnvironmentObject var authViewModel: AuthViewModel

        @State private var notificationsEnabled = true
        @State private var workStartTime = Date()
        @State private var workEndTime = Date()

        // (optional local-only)
        @State private var emailUpdates = false
        

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
                    Button("Export Data") { }
                    Button("Clear Cache") { }
                    Button("Delete Account", role: .destructive) { }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        Task { await saveAndDismiss() }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                }
            }
            .onAppear {
                guard let user = authViewModel.currentUser else { return }

                notificationsEnabled = user.notificationsEnabled ?? true

                let parser = DateFormatter()
                parser.dateFormat = "HH:mm:ss"

                if let s = user.workStartTime, let d = parser.date(from: s) { workStartTime = d }
                if let e = user.workEndTime, let d = parser.date(from: e) { workEndTime = d }
            }
        }
    }

    private func loadFromCurrentUser() {
        guard let user = authViewModel.currentUser else { return }

        notificationsEnabled = user.notificationsEnabled ?? true

        let parser = DateFormatter()
        parser.dateFormat = "HH:mm:ss"

        if let s = user.workStartTime, let d = parser.date(from: s) {
            workStartTime = d
        }
        if let e = user.workEndTime, let d = parser.date(from: e) {
            workEndTime = d
        }

        // optional: load local-only toggles
        emailUpdates = UserDefaults.standard.bool(forKey: "emailUpdates")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }

    private func saveAndDismiss() async {
        guard let user = authViewModel.currentUser else {
            dismiss()
            return
        }

        // save local-only toggles
        UserDefaults.standard.set(emailUpdates, forKey: "emailUpdates")
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        let start = formatter.string(from: workStartTime)
        let end = formatter.string(from: workEndTime)

        await authViewModel.updateProfile(
            name: user.name,
            workStartTime: start,
            workEndTime: end,
            timezone: TimeZone.current.identifier,
            notificationsEnabled: notificationsEnabled
        )

        if authViewModel.errorMessage == nil {
            dismiss()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}

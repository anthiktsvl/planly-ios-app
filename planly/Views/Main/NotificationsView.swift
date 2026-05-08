//
//  NotificationsView.swift
//  Planly
//
//  View for managing notification settings
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var taskNotifications = true
    @State private var meetingNotifications = true
    @State private var projectNotifications = true
    @State private var dailySummary = true
    @State private var taskReminders = true
    @State private var meetingReminders = true
    @State private var completionCelebrations = true
    
    @State private var reminderMinutes = 15
    @State private var dailySummaryTime = Date()
    
    @State private var pendingNotifications: [UNNotificationRequest] = []
    @State private var showingPermissionAlert = false
    
    let reminderOptions = [5, 10, 15, 30, 60]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            ColorTheme.primary(for: themeManager.currentTheme),
                                            ColorTheme.dark(for: themeManager.currentTheme)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Notifications")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Stay updated with your tasks and meetings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Permission Status
                        if !notificationManager.isAuthorized {
                            PermissionBanner(action: {
                                Task {
                                    let granted = await notificationManager.requestAuthorization()
                                    if !granted {
                                        showingPermissionAlert = true
                                    }
                                }
                            })
                        }
                        
                        // Master Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Enable Notifications")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Toggle(isOn: $notificationManager.notificationsEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(ColorTheme.primary(for: themeManager.currentTheme))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("All Notifications")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("Receive alerts for all events")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .tint(ColorTheme.primary(for: themeManager.currentTheme))
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Task Notifications
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tasks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    icon: "checkmark.circle.fill",
                                    title: "New Tasks",
                                    subtitle: "Get notified when tasks are added",
                                    color: .pink,
                                    isOn: $taskNotifications
                                )
                                
                                Divider()
                                    .padding(.leading, 64)
                                
                                NotificationToggle(
                                    icon: "clock.fill",
                                    title: "Task Reminders",
                                    subtitle: "Remind me before tasks start",
                                    color: .orange,
                                    isOn: $taskReminders
                                )
                                
                                Divider()
                                    .padding(.leading, 64)
                                
                                NotificationToggle(
                                    icon: "star.fill",
                                    title: "Completion Celebrations",
                                    subtitle: "Celebrate when you complete tasks",
                                    color: .yellow,
                                    isOn: $completionCelebrations
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Meeting Notifications
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meetings")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    icon: "video.fill",
                                    title: "New Meetings",
                                    subtitle: "Get notified when meetings are scheduled",
                                    color: .blue,
                                    isOn: $meetingNotifications
                                )
                                
                                Divider()
                                    .padding(.leading, 64)
                                
                                NotificationToggle(
                                    icon: "alarm.fill",
                                    title: "Meeting Reminders",
                                    subtitle: "Remind me before meetings start",
                                    color: .purple,
                                    isOn: $meetingReminders
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Project Notifications
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Projects")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                NotificationToggle(
                                    icon: "folder.fill",
                                    title: "New Projects",
                                    subtitle: "Get notified when projects are created",
                                    color: .purple,
                                    isOn: $projectNotifications
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                // Reminder Time
                                VStack(alignment: .leading, spacing: 8) {
                                    Label {
                                        Text("Reminder Time")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    } icon: {
                                        Image(systemName: "clock")
                                            .foregroundColor(ColorTheme.primary(for: themeManager.currentTheme))
                                    }
                                    
                                    Picker("Minutes Before", selection: $reminderMinutes) {
                                        ForEach(reminderOptions, id: \.self) { minutes in
                                            Text("\(minutes) minutes").tag(minutes)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    
                                    Text("Receive reminders \(reminderMinutes) minutes before events")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                // Daily Summary
                                VStack(alignment: .leading, spacing: 8) {
                                    Toggle(isOn: $dailySummary) {
                                        Label {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Daily Summary")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                
                                                Text("Morning overview of your day")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        } icon: {
                                            Image(systemName: "sun.max.fill")
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .tint(ColorTheme.primary(for: themeManager.currentTheme))
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Active Notifications
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Active Notifications")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(pendingNotifications.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            if pendingNotifications.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No pending notifications")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(pendingNotifications.prefix(5), id: \.identifier) { notification in
                                        PendingNotificationRow(notification: notification)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Clear All Button
                        if !pendingNotifications.isEmpty {
                            Button {
                                Task {
                                    await notificationManager.cancelAllNotifications()
                                    await loadPendingNotifications()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear All Notifications")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ColorTheme.primary(for: themeManager.currentTheme),
                                ColorTheme.dark(for: themeManager.currentTheme)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
            .onAppear {
                loadSettings()
                Task {
                    await loadPendingNotifications()
                }
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive alerts.")
            }
        }
    }
    
    private func loadSettings() {
        taskNotifications = UserDefaults.standard.bool(forKey: "taskNotifications") 
        meetingNotifications = UserDefaults.standard.bool(forKey: "meetingNotifications")
        projectNotifications = UserDefaults.standard.bool(forKey: "projectNotifications")
        dailySummary = UserDefaults.standard.bool(forKey: "dailySummary")
        taskReminders = UserDefaults.standard.bool(forKey: "taskReminders")
        meetingReminders = UserDefaults.standard.bool(forKey: "meetingReminders")
        completionCelebrations = UserDefaults.standard.bool(forKey: "completionCelebrations")
        reminderMinutes = UserDefaults.standard.integer(forKey: "reminderMinutes")
        
        // Set defaults if first time
        if reminderMinutes == 0 {
            reminderMinutes = 15
            taskNotifications = true
            meetingNotifications = true
            projectNotifications = true
            dailySummary = true
            taskReminders = true
            meetingReminders = true
            completionCelebrations = true
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(taskNotifications, forKey: "taskNotifications")
        UserDefaults.standard.set(meetingNotifications, forKey: "meetingNotifications")
        UserDefaults.standard.set(projectNotifications, forKey: "projectNotifications")
        UserDefaults.standard.set(dailySummary, forKey: "dailySummary")
        UserDefaults.standard.set(taskReminders, forKey: "taskReminders")
        UserDefaults.standard.set(meetingReminders, forKey: "meetingReminders")
        UserDefaults.standard.set(completionCelebrations, forKey: "completionCelebrations")
        UserDefaults.standard.set(reminderMinutes, forKey: "reminderMinutes")
    }
    
    private func loadPendingNotifications() async {
        pendingNotifications = await notificationManager.getPendingNotifications()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Permission Banner
struct PermissionBanner: View {
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notifications Disabled")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Enable notifications to stay updated")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Enable") {
                action()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Notification Toggle
struct NotificationToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .tint(color)
        .padding()
    }
}

// MARK: - Pending Notification Row
struct PendingNotificationRow: View {
    let notification: UNNotificationRequest
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForNotification)
                .foregroundColor(colorForNotification)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.content.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(notification.content.body)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                Text(nextTriggerDate, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger {
                Text("\(Int(trigger.timeInterval))s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var iconForNotification: String {
        if notification.content.categoryIdentifier.contains("TASK") {
            return "checkmark.circle.fill"
        } else if notification.content.categoryIdentifier.contains("MEETING") {
            return "video.fill"
        } else if notification.content.categoryIdentifier.contains("PROJECT") {
            return "folder.fill"
        }
        return "bell.fill"
    }
    
    private var colorForNotification: Color {
        if notification.content.categoryIdentifier.contains("TASK") {
            return .pink
        } else if notification.content.categoryIdentifier.contains("MEETING") {
            return .blue
        } else if notification.content.categoryIdentifier.contains("PROJECT") {
            return .purple
        }
        return .gray
    }
}

#Preview {
    NotificationsView()
        .environmentObject(ThemeManager())
}

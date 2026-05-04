//
//  NotificationsView.swift
//  Planly
//
//  View for displaying in-app notifications
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if notificationManager.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Unread count banner
                            if notificationManager.hasUnread {
                                UnreadBanner(count: notificationManager.unreadCount) {
                                    withAnimation {
                                        notificationManager.markAllAsRead()
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            // Notifications list
                            LazyVStack(spacing: 12) {
                                ForEach(notificationManager.notifications) { notification in
                                    NotificationCard(notification: notification)
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !notificationManager.notifications.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                withAnimation {
                                    notificationManager.markAllAsRead()
                                }
                            } label: {
                                Label("Mark All as Read", systemImage: "checkmark.circle")
                            }
                            
                            Button(role: .destructive) {
                                showingClearAlert = true
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
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
                }
            }
            .alert("Clear All Notifications", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    withAnimation {
                        notificationManager.clearAll()
                    }
                }
            } message: {
                Text("This will permanently delete all your notifications.")
            }
        }
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var themeManager: ThemeManager
    let notification: AppNotification
    @State private var showingDeleteAlert = false
    
    var notificationColor: Color {
        switch notification.type.colorName {
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Button {
            if !notification.isRead {
                withAnimation {
                    notificationManager.markAsRead(notification)
                }
            }
        } label: {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(notificationColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: notification.type.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(notificationColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.subheadline)
                            .fontWeight(notification.isRead ? .medium : .bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ColorTheme.primary(for: themeManager.currentTheme),
                                            ColorTheme.dark(for: themeManager.currentTheme)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text(timeAgoString(from: notification.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Delete button
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: notification.isRead ? .black.opacity(0.03) : ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1),
                        radius: notification.isRead ? 4 : 8,
                        x: 0,
                        y: notification.isRead ? 2 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        notification.isRead ? Color.clear : ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Notification", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    notificationManager.deleteNotification(notification)
                }
            }
        } message: {
            Text("This notification will be permanently deleted.")
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Unread Banner
struct UnreadBanner: View {
    @EnvironmentObject var themeManager: ThemeManager
    let count: Int
    let action: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "bell.badge.fill")
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
                
                Text("\(count) unread notification\(count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button("Mark All Read") {
                action()
            }
            .font(.caption)
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1))
        )
    }
}

// MARK: - Empty State
struct EmptyNotificationsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.slash.fill")
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
            }
            
            VStack(spacing: 8) {
                Text("No Notifications")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("You're all caught up!\nNew notifications will appear here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(NotificationManager())
        .environmentObject(ThemeManager())
}

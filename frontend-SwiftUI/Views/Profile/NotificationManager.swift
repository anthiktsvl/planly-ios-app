//
//  NotificationManager.swift
//  Planly
//
//  Manages in-app notifications
//

import Foundation
import Combine

@MainActor
class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var hasUnread: Bool {
        unreadCount > 0
    }
    
    init() {
        loadNotifications()
        // Add some sample notifications for demonstration
        addSampleNotifications()
    }
    
    // MARK: - Public Methods
    
    func addNotification(
        title: String,
        message: String,
        type: NotificationType,
        relatedItemId: String? = nil
    ) {
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            relatedItemId: relatedItemId
        )
        notifications.insert(notification, at: 0)
        saveNotifications()
    }
    
    func markAsRead(_ notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
        saveNotifications()
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        saveNotifications()
    }
    
    func deleteNotification(_ notification: AppNotification) {
        notifications.removeAll { $0.id == notification.id }
        saveNotifications()
    }
    
    func clearAll() {
        notifications.removeAll()
        saveNotifications()
    }
    
    // MARK: - Private Methods
    
    private func loadNotifications() {
        guard let data = UserDefaults.standard.data(forKey: "appNotifications"),
              let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) else {
            return
        }
        notifications = decoded
    }
    
    private func saveNotifications() {
        guard let encoded = try? JSONEncoder().encode(notifications) else { return }
        UserDefaults.standard.set(encoded, forKey: "appNotifications")
    }
    
    private func addSampleNotifications() {
        // Only add samples if there are no notifications
        guard notifications.isEmpty else { return }
        
        let samples = [
            AppNotification(
                title: "Task Due Soon",
                message: "Your task 'Complete project proposal' is due in 2 hours",
                type: .taskDue,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            AppNotification(
                title: "Meeting Reminder",
                message: "Team standup starts in 15 minutes",
                type: .meetingReminder,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: true
            ),
            AppNotification(
                title: "Task Completed",
                message: "You completed 'Review design mockups'",
                type: .taskCompleted,
                timestamp: Date().addingTimeInterval(-86400)
            ),
            AppNotification(
                title: "Project Update",
                message: "New task added to 'Mobile App Development'",
                type: .projectUpdate,
                timestamp: Date().addingTimeInterval(-172800),
                isRead: true
            ),
            AppNotification(
                title: "Welcome to Planly!",
                message: "Thanks for using Planly. Get started by creating your first task.",
                type: .general,
                timestamp: Date().addingTimeInterval(-259200),
                isRead: true
            )
        ]
        
        notifications = samples
        saveNotifications()
    }
}

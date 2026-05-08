//
//  NotificationManager.swift
//  Planly
//
//  Manages all local notifications for tasks, meetings, and app events
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var notificationsEnabled = true
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {
        Task {
            await checkAuthorization()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
            
            return granted
        } catch {
            print("❌ Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
        print("📱 Notification authorization status: \(settings.authorizationStatus.rawValue)")
    }
    
    // MARK: - Task Notifications
    
    func scheduleTaskNotification(for task: TaskItem) async {
        guard isAuthorized && notificationsEnabled else {
            print("⚠️ Notifications not authorized or disabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New Task Added"
        content.body = task.name
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_CATEGORY"
        
        // Add custom data
        content.userInfo = [
            "taskId": task.id ?? 0,
            "taskName": task.name,
            "type": "task_added"
        ]
        
        // Schedule for 3 seconds from now (for testing)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_added_\(task.id ?? 0)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled notification for new task: \(task.name)")
        } catch {
            print("❌ Error scheduling task notification: \(error)")
        }
    }
    
    func scheduleTaskReminderNotification(for task: TaskItem, minutesBefore: Int = 15) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        guard let startTime = task.startTime else {
            print("⚠️ Task has no start time, cannot schedule reminder")
            return
        }
        
        // Calculate reminder time
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: startTime)!
        
        // Only schedule if the reminder is in the future
        guard reminderDate > Date() else {
            print("⚠️ Reminder time is in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "\(task.name) starts in \(minutesBefore) minutes"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_REMINDER"
        
        content.userInfo = [
            "taskId": task.id ?? 0,
            "taskName": task.name,
            "type": "task_reminder"
        ]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_reminder_\(task.id ?? 0)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled task reminder for: \(task.name) at \(reminderDate)")
        } catch {
            print("❌ Error scheduling task reminder: \(error)")
        }
    }
    
    func scheduleTaskCompletionNotification(for task: TaskItem) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Completed! 🎉"
        content.body = "Great job completing '\(task.name)'"
        content.sound = .default
        content.categoryIdentifier = "TASK_COMPLETED"
        
        content.userInfo = [
            "taskId": task.id ?? 0,
            "taskName": task.name,
            "type": "task_completed"
        ]
        
        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_completed_\(task.id ?? 0)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled completion notification for: \(task.name)")
        } catch {
            print("❌ Error scheduling completion notification: \(error)")
        }
    }
    
    // MARK: - Meeting Notifications
    
    func scheduleMeetingNotification(for meeting: Meeting) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Meeting Added"
        content.body = "\(meeting.title) on \(meeting.date.formatted(date: .abbreviated, time: .omitted))"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MEETING_CATEGORY"
        
        content.userInfo = [
            "meetingId": meeting.id ?? 0,
            "meetingTitle": meeting.title,
            "type": "meeting_added"
        ]
        
        // Schedule for 3 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "meeting_added_\(meeting.id ?? 0)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled notification for new meeting: \(meeting.title)")
        } catch {
            print("❌ Error scheduling meeting notification: \(error)")
        }
    }
    
    func scheduleMeetingReminderNotification(for meeting: Meeting, minutesBefore: Int = 15) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: meeting.startTime)!
        
        guard reminderDate > Date() else {
            print("⚠️ Meeting reminder time is in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Meeting Reminder"
        content.body = "\(meeting.title) starts in \(minutesBefore) minutes"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MEETING_REMINDER"
        
        content.userInfo = [
            "meetingId": meeting.id ?? 0,
            "meetingTitle": meeting.title,
            "type": "meeting_reminder"
        ]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "meeting_reminder_\(meeting.id ?? 0)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled meeting reminder for: \(meeting.title) at \(reminderDate)")
        } catch {
            print("❌ Error scheduling meeting reminder: \(error)")
        }
    }
    
    // MARK: - Project Notifications
    
    func scheduleProjectNotification(for project: Project) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Project Created"
        content.body = project.name
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PROJECT_CATEGORY"
        
        content.userInfo = [
            "projectId": project.id ?? 0,
            "projectName": project.name,
            "type": "project_added"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "project_added_\(project.id ?? 0)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled notification for new project: \(project.name)")
        } catch {
            print("❌ Error scheduling project notification: \(error)")
        }
    }
    
    func scheduleProjectDeadlineNotification(for project: Project) async {
        guard isAuthorized && notificationsEnabled else { return }
        guard let deadline = project.deadline else { return }
        
        // Schedule notification for 1 day before deadline
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: deadline)!
        
        guard reminderDate > Date() else {
            print("⚠️ Project deadline reminder is in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Project Deadline Tomorrow"
        content.body = "\(project.name) is due tomorrow!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PROJECT_DEADLINE"
        
        content.userInfo = [
            "projectId": project.id ?? 0,
            "projectName": project.name,
            "type": "project_deadline"
        ]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "project_deadline_\(project.id ?? 0)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled project deadline notification for: \(project.name)")
        } catch {
            print("❌ Error scheduling project deadline notification: \(error)")
        }
    }
    
    // MARK: - Daily Summary Notifications
    
    func scheduleDailySummaryNotification(taskCount: Int, meetingCount: Int) async {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! ☀️"
        content.body = "You have \(taskCount) tasks and \(meetingCount) meetings today"
        content.sound = .default
        content.badge = taskCount + meetingCount
        content.categoryIdentifier = "DAILY_SUMMARY"
        
        content.userInfo = ["type": "daily_summary"]
        
        // Schedule for 8 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_summary",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Scheduled daily summary notification")
        } catch {
            print("❌ Error scheduling daily summary: \(error)")
        }
    }
    
    // MARK: - Notification Management
    
    func cancelNotification(withIdentifier identifier: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled notification: \(identifier)")
    }
    
    func cancelAllTaskNotifications(for taskId: Int) async {
        let identifiers = [
            "task_added_\(taskId)",
            "task_reminder_\(taskId)",
            "task_completed_\(taskId)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Cancelled all notifications for task: \(taskId)")
    }
    
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("🗑️ Cancelled all notifications")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func getBadgeCount() async -> Int {
        let delivered = await center.deliveredNotifications()
        return delivered.count
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        print("🔔 Badge cleared")
    }
    
    // MARK: - Notification Categories
    
    func setupNotificationCategories() {
        // Task actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Complete",
            options: .foreground
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Remind me in 10 min",
            options: []
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Meeting actions
        let joinAction = UNNotificationAction(
            identifier: "JOIN_ACTION",
            title: "Join Meeting",
            options: .foreground
        )
        
        let meetingCategory = UNNotificationCategory(
            identifier: "MEETING_REMINDER",
            actions: [joinAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([taskCategory, meetingCategory])
        print("✅ Notification categories configured")
    }
}

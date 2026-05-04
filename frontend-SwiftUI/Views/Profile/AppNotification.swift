//
//  AppNotification.swift
//  Planly
//
//  Model for in-app notifications
//

import Foundation

struct AppNotification: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    let relatedItemId: String? // ID of related task, meeting, or project
    
    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        type: NotificationType,
        timestamp: Date = Date(),
        isRead: Bool = false,
        relatedItemId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.relatedItemId = relatedItemId
    }
}

enum NotificationType: String, Codable {
    case taskDue = "task_due"
    case taskCompleted = "task_completed"
    case meetingReminder = "meeting_reminder"
    case projectUpdate = "project_update"
    case general = "general"
    
    var iconName: String {
        switch self {
        case .taskDue:
            return "clock.fill"
        case .taskCompleted:
            return "checkmark.circle.fill"
        case .meetingReminder:
            return "video.fill"
        case .projectUpdate:
            return "folder.fill"
        case .general:
            return "bell.fill"
        }
    }
    
    var colorName: String {
        switch self {
        case .taskDue:
            return "orange"
        case .taskCompleted:
            return "green"
        case .meetingReminder:
            return "blue"
        case .projectUpdate:
            return "purple"
        case .general:
            return "gray"
        }
    }
}

//
//  Models.swift
//  Planly
//
/* Core data types used throughout the app (tasks, projects, meetings, etc.). Most of these conform to Codable so they can be sent to / decoded from the API. CodingKeys are used to bridge Swift naming to backend snake_case.
 */

import Foundation
import SwiftUI

struct TaskItem: Identifiable, Codable {
    var id: Int?
    var name: String
    var description: String
    var category: String
    var date: Date
    var priority: Priority
    var isCompleted: Bool
    var startTime: Date?
    var endTime: Date?

    // ✅ NEW: project assignment
    var projectId: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case date
        case priority
        case isCompleted = "is_completed"
        case startTime = "start_time"
        case endTime = "end_time"

        // ✅ backend column is project_id on responses
        case projectId = "project_id"
    }
}

// MARK: - Subtask Model
struct Subtask: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isCompleted: Bool = false
}

// MARK: - Project
struct Project: Identifiable, Codable {
    var id: Int?
    var name: String
    var description: String
    var estimatedHours: Int
    var deadline: Date?
    var category: String
    var color: String
    var tasksCompleted: Int
    var totalTasks: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case estimatedHours = "estimated_hours"
        case deadline
        case category
        case color
        case tasksCompleted = "tasks_completed"
        case totalTasks = "total_tasks"
    }
    
    var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(tasksCompleted) / Double(totalTasks)
    }
}

// MARK: - Meeting
struct Meeting: Identifiable, Codable {
    var id: Int?  // ← Changed from UUID to Int?
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var attendeeEmail: String
    var status: String?  // ← Keep as String? for now
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case attendeeEmail = "attendee_email"
        case status
    }
}
// MARK: - Available Time Slot
struct TimeSlot: Identifiable {
    var id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool = true
}

// MARK: - User Profile
struct UserProfile: Identifiable {
    var id: Int
    var name: String
    var email: String

    // persisted settings
    var workStartTime: String?
    var workEndTime: String?
    var timezone: String?
    var notificationsEnabled: Bool?
}

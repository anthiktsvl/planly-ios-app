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
    var estimatedHours: Double
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        // estimated_hours can arrive as a number or a string like "1.00"
        if let doubleValue = try? container.decode(Double.self, forKey: .estimatedHours) {
            estimatedHours = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .estimatedHours), let parsed = Double(stringValue) {
            estimatedHours = parsed
        } else {
            // default to 0 if missing or incompatible
            estimatedHours = 0
        }
        deadline = try container.decodeIfPresent(Date.self, forKey: .deadline)
        category = try container.decode(String.self, forKey: .category)
        color = try container.decode(String.self, forKey: .color)
        tasksCompleted = try container.decode(Int.self, forKey: .tasksCompleted)
        totalTasks = try container.decode(Int.self, forKey: .totalTasks)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(estimatedHours, forKey: .estimatedHours)
        try container.encodeIfPresent(deadline, forKey: .deadline)
        try container.encode(category, forKey: .category)
        try container.encode(color, forKey: .color)
        try container.encode(tasksCompleted, forKey: .tasksCompleted)
        try container.encode(totalTasks, forKey: .totalTasks)
    }
    
    init(
        id: Int?,
        name: String,
        description: String,
        estimatedHours: Double,
        deadline: Date?,
        category: String,
        color: String,
        tasksCompleted: Int,
        totalTasks: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.estimatedHours = estimatedHours
        self.deadline = deadline
        self.category = category
        self.color = color
        self.tasksCompleted = tasksCompleted
        self.totalTasks = totalTasks
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


//
//  APIModels.swift
//  Planly
//

/*  DTOs (Data Transfer Objects) that match the backend JSON payloads. These are intentionally separate from the app’s “UI models” in Models.swift. Reason: APIs usually represent dates as Strings, use snake_case keys, and may have optional fields depending on the endpoint/version.
    Typical flow: API JSON <-> APIModels (Codable) -> mapped into app Models (TaskItem/Meeting/Project)
*/

import Foundation

// MARK: - Auth
struct SignUpRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct SignInRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: APIUserProfile
}

struct APIUserProfile: Codable {
    let id: Int
    let name: String
    let email: String

    // settings from backend (/auth/me + /auth/profile)
    let workStartTime: String?
    let workEndTime: String?
    let timezone: String?
    let notificationsEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case workStartTime = "work_start_time"
        case workEndTime = "work_end_time"
        case timezone
        case notificationsEnabled = "notifications_enabled"
    }
}
struct UserProfileResponse: Codable {
    let user: APIUserProfile
}

struct UpdateProfileRequest: Codable {
    let name: String
    let workStartTime: String?
    let workEndTime: String?
    let timezone: String?
    let notificationsEnabled: Bool?
}

struct UpdateProfileResponse: Codable {
    let message: String
    let user: APIUserProfile
}

// MARK: - Tasks
struct TaskItemAPI: Codable {
    let id: Int?
    let name: String
    let description: String?
    let category: String?
    let date: String
    let priority: String
    let isCompleted: Bool
    let startTime: String?
    let endTime: String?

    // ✅ NEW
    let projectId: Int?

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

        // ✅ backend responses use project_id
        case projectId = "project_id"
    }
}

struct CreateTaskRequest: Codable {
    let name: String
    let description: String
    let category: String
    let date: String
    let priority: String
    let isCompleted: Bool
    let startTime: String?
    let endTime: String?

    // ✅ NEW
    let projectId: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case date
        case priority
        case isCompleted = "is_completed"
        case startTime = "start_time"
        case endTime = "end_time"

        // ✅ Node controller expects req.body.projectId (camelCase)
        case projectId = "projectId"
    }
}

struct TaskItemResponse: Codable {
    let task: TaskItemAPI
}

struct TasksResponse: Codable {
    let tasks: [TaskItemAPI]
}

// MARK: - Meetings
struct MeetingAPI: Codable {
    let id: Int?
    let title: String
    let description: String?
    let date: String
    let startTime: String
    let endTime: String
    let attendeeEmail: String
    let status: String?
    
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

struct CreateMeetingRequest: Codable {
    let title: String
    let description: String
    let date: String
    let startTime: String
    let endTime: String
    let attendeeEmail: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case attendeeEmail = "attendee_email"
    }
}

struct MeetingResponse: Codable {
    let meeting: MeetingAPI
}

struct MeetingsResponse: Codable {
    let meetings: [MeetingAPI]
}

// MARK: - Projects
struct ProjectAPI: Codable {
    let id: Int?
    let name: String
    let description: String?
    let estimatedHours: DoubleOrString?
    let deadline: String?
    let category: String?
    let color: String?

    // ✅ can be 0 or "0"
    let tasksCompleted: IntOrString?
    let totalTasks: IntOrString?
    let incompleteTasks: IntOrString?
    let completedTasks: IntOrString?

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
        case incompleteTasks = "incomplete_tasks"
        case completedTasks = "completed_tasks"
    }
}

struct CreateProjectRequest: Codable {
    let name: String
    let description: String
    let estimatedHours: Double
    let deadline: String?
    let category: String
    let color: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case estimatedHours = "estimatedHours" // ✅ FIX (was "estimated_hours")
        case deadline
        case category
        case color
    }
}

struct ProjectResponse: Codable {
    let project: ProjectAPI
}

struct ProjectsResponse: Codable {
    let projects: [ProjectAPI]
}

struct ProjectDetailResponse: Codable {
    let project: ProjectAPI
    let tasks: [TaskItemAPI]
}

struct UpdateProjectRequest: Codable {
    let name: String
    let description: String
    let estimatedHours: Int
    let deadline: String?
    let category: String
    let color: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case estimatedHours = "estimatedHours" // matches backend
        case deadline
        case category
        case color
    }
}

/// Decodes an Int that might be encoded as either a JSON number (0) or a JSON string ("0")
struct IntOrString: Codable {
    let value: Int

    init(_ value: Int) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intVal = try? container.decode(Int.self) {
            self.value = intVal
            return
        }

        if let strVal = try? container.decode(String.self),
           let intVal = Int(strVal) {
            self.value = intVal
            return
        }

        throw DecodingError.typeMismatch(
            Int.self,
            .init(codingPath: decoder.codingPath,
                  debugDescription: "Expected Int or String convertible to Int")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
/// Decodes a Double that might be encoded as either a JSON number (1.0) or a JSON string ("1.00")
struct DoubleOrString: Codable {
    let value: Double

    init(_ value: Double) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let doubleVal = try? container.decode(Double.self) {
            self.value = doubleVal
            return
        }

        if let strVal = try? container.decode(String.self),
           let doubleVal = Double(strVal) {
            self.value = doubleVal
            return
        }

        throw DecodingError.typeMismatch(
            Double.self,
            .init(codingPath: decoder.codingPath,
                  debugDescription: "Expected Double or String convertible to Double")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}


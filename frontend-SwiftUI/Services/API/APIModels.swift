//
//  APIModels.swift
//  Planly
//

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
}

struct UserProfileResponse: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case date
        case priority
        case isCompleted = "is_completed"
        case startTime = "start_time"
        case endTime = "end_time"
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
    let estimatedHours: Int?  
    let deadline: String?
    let category: String?
    let color: String?
    let tasksCompleted: Int?
    let totalTasks: Int?
    
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
}

struct CreateProjectRequest: Codable {
    let name: String
    let description: String
    let estimatedHours: Int
    let deadline: String?
    let category: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case estimatedHours = "estimated_hours"
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

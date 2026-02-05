//
//  APIService.swift
//  Planly
//
//  Main API Service
//

import Foundation

class APIService {
    static let shared = APIService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Auth
    
    func signUp(name: String, email: String, password: String) async throws -> AuthResponse {
        let request = SignUpRequest(name: name, email: email, password: password)
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        let response: AuthResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.signup,
            method: HTTPMethod.post,
            body: body,
            requiresAuth: false
        )
        
        UserDefaults.standard.set(response.token, forKey: "authToken")
        return response
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let request = SignInRequest(email: email, password: password)
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        let response: AuthResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.signin,
            method: HTTPMethod.post,
            body: body,
            requiresAuth: false
        )
        
        UserDefaults.standard.set(response.token, forKey: "authToken")
        return response
    }
    
    func getCurrentUser() async throws -> APIUserProfile {
        let response: UserProfileResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.me,
            method: HTTPMethod.get,
            body: nil,
            requiresAuth: true
        )
        return response.user
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    // MARK: - Tasks
    
    func getTasks() async throws -> [TaskItemAPI] {
        let response: TasksResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasks,
            method: HTTPMethod.get,
            body: nil,
            requiresAuth: true
        )
        return response.tasks
    }
    
    func getTasksByDate(_ date: Date) async throws -> [TaskItemAPI] {
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        let response: TasksResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasksByDate(String(dateString)),
            method: HTTPMethod.get,
            body: nil,
            requiresAuth: true
        )
        return response.tasks
    }
    
    func createTask(_ task: TaskItem) async throws -> TaskItemAPI {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: task.date)
        
        var startTimeString: String? = nil
        if let startTime = task.startTime {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            startTimeString = timeFormatter.string(from: startTime)
        }
        
        var endTimeString: String? = nil
        if let endTime = task.endTime {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            endTimeString = timeFormatter.string(from: endTime)
        }
        
        let request = CreateTaskRequest(
            name: task.name,
            description: task.description,
            category: task.category,
            date: dateString,
            priority: task.priority.rawValue,
            isCompleted: task.isCompleted,
            startTime: startTimeString,
            endTime: endTimeString
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        print("📤 Sending task to API: \(String(data: body, encoding: .utf8) ?? "")")
        
        let response: TaskItemResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasks,
            method: HTTPMethod.post,
            body: body,
            requiresAuth: true
        )
        
        print("📥 API Response: \(response.task)")
        return response.task
    }
    
    func toggleTaskCompletion(taskId: Int) async throws -> TaskItemAPI {
        let response: TaskItemResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.toggleTask(taskId),
            method: HTTPMethod.patch,
            body: nil,
            requiresAuth: true
        )
        return response.task
    }
    
    func deleteTask(taskId: Int) async throws {
        try await networkManager.request(
            endpoint: APIConfig.Endpoints.task(taskId),
            method: HTTPMethod.delete,
            body: nil,
            requiresAuth: true
        )
    }
    
    // MARK: - Meetings
    
    func getMeetings() async throws -> [MeetingAPI] {
        let response: MeetingsResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.meetings,
            method: HTTPMethod.get,
            body: nil,
            requiresAuth: true
        )
        return response.meetings
    }
    
    func createMeeting(_ meeting: Meeting) async throws -> MeetingAPI {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: meeting.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let startTimeString = timeFormatter.string(from: meeting.startTime)
        let endTimeString = timeFormatter.string(from: meeting.endTime)
        
        let request = CreateMeetingRequest(
            title: meeting.title,
            description: meeting.description,
            date: dateString,
            startTime: startTimeString,
            endTime: endTimeString,
            attendeeEmail: meeting.attendeeEmail
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        let response: MeetingResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.meetings,
            method: HTTPMethod.post,
            body: body,
            requiresAuth: true
        )
        
        return response.meeting
    }
    
    func cancelMeeting(meetingId: Int) async throws {
        try await networkManager.request(
            endpoint: APIConfig.Endpoints.cancelMeeting(meetingId),
            method: HTTPMethod.patch,
            body: nil,
            requiresAuth: true
        )
    }
    
    // MARK: - Projects
    
    func getProjects() async throws -> [ProjectAPI] {
        let response: ProjectsResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.projects,
            method: HTTPMethod.get,
            body: nil,
            requiresAuth: true
        )
        return response.projects
    }
    
    func createProject(_ project: Project) async throws -> ProjectAPI {
        var deadlineString: String? = nil
        if let deadline = project.deadline {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            deadlineString = dateFormatter.string(from: deadline)
        }
        
        let request = CreateProjectRequest(
            name: project.name,
            description: project.description,
            estimatedHours: project.estimatedHours,  // ← No conversion, it's already Int
            deadline: deadlineString,
            category: project.category,
            color: project.color  // ← Use project's color, not hardcoded
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        let response: ProjectResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.projects,
            method: HTTPMethod.post,
            body: body,
            requiresAuth: true
        )
        
        return response.project
    }
}

// MARK: - Date Formatting Extension
extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}

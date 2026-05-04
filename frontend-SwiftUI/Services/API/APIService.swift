//
//  APIService.swift
//  Planly
//
//  Main API Service
//

import Foundation

final class APIService {
    static let shared = APIService()
    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Auth

    func signUp(name: String, email: String, password: String) async throws -> AuthResponse {
        let request = SignUpRequest(name: name, email: email, password: password)
        let body = try JSONEncoder().encode(request)

        let response: AuthResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.signup,
            method: .post,
            body: body,
            requiresAuth: false
        )

        UserDefaults.standard.set(response.token, forKey: "authToken")
        return response
    }

    func signIn(email: String, password: String) async throws -> AuthResponse {
        let request = SignInRequest(email: email, password: password)
        let body = try JSONEncoder().encode(request)

        let response: AuthResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.signin,
            method: .post,
            body: body,
            requiresAuth: false
        )

        UserDefaults.standard.set(response.token, forKey: "authToken")
        return response
    }

    func getCurrentUser() async throws -> APIUserProfile {
        let response: UserProfileResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.me,
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response.user
    }
    
    func updateProfile(
        name: String,
        workStartTime: String?,
        workEndTime: String?,
        timezone: String?,
        notificationsEnabled: Bool?
    ) async throws -> APIUserProfile {
        let request = UpdateProfileRequest(
            name: name,
            workStartTime: workStartTime,
            workEndTime: workEndTime,
            timezone: timezone,
            notificationsEnabled: notificationsEnabled
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(request)

        let response: UpdateProfileResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.updateProfile,
            method: .put,
            body: body,
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
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response.tasks
    }

    func getTasksByDate(_ date: Date) async throws -> [TaskItemAPI] {
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        let response: TasksResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasksByDate(String(dateString)),
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response.tasks
    }

    func createTask(_ task: TaskItem) async throws -> TaskItemAPI {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: task.date)

        var startTimeString: String? = nil
        if let startTime = task.startTime {
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm:ss"
            startTimeString = tf.string(from: startTime)
        }

        var endTimeString: String? = nil
        if let endTime = task.endTime {
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm:ss"
            endTimeString = tf.string(from: endTime)
        }

        let request = CreateTaskRequest(
            name: task.name,
            description: task.description,
            category: task.category,
            date: dateString,
            priority: task.priority.rawValue,
            isCompleted: task.isCompleted,
            startTime: startTimeString,
            endTime: endTimeString,
            projectId: task.projectId
        )

        let body = try JSONEncoder().encode(request)

        let response: TaskItemResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasks,
            method: .post,
            body: body,
            requiresAuth: true
        )

        return response.task
    }

    func toggleTaskCompletion(taskId: Int) async throws -> TaskItemAPI {
        let response: TaskItemResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.toggleTask(taskId),
            method: .patch,
            body: nil,
            requiresAuth: true
        )
        return response.task
    }

    func deleteTask(taskId: Int) async throws {
        try await networkManager.request(
            endpoint: APIConfig.Endpoints.task(taskId),
            method: .delete,
            body: nil,
            requiresAuth: true
        )
    }

    // MARK: - Meetings

    func getMeetings() async throws -> [MeetingAPI] {
        let response: MeetingsResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.meetings,
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response.meetings
    }

    func createMeeting(_ meeting: Meeting) async throws -> MeetingAPI {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: meeting.date)

        let tf = DateFormatter()
        tf.dateFormat = "HH:mm:ss"
        let startTimeString = tf.string(from: meeting.startTime)
        let endTimeString = tf.string(from: meeting.endTime)

        let request = CreateMeetingRequest(
            title: meeting.title,
            description: meeting.description,
            date: dateString,
            startTime: startTimeString,
            endTime: endTimeString,
            attendeeEmail: meeting.attendeeEmail
        )

        let body = try JSONEncoder().encode(request)

        let response: MeetingResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.meetings,
            method: .post,
            body: body,
            requiresAuth: true
        )

        return response.meeting
    }

    func cancelMeeting(meetingId: Int) async throws {
        try await networkManager.request(
            endpoint: APIConfig.Endpoints.cancelMeeting(meetingId),
            method: .patch,
            body: nil,
            requiresAuth: true
        )
    }

    // MARK: - Projects

    func getProjects() async throws -> [ProjectAPI] {
        let response: ProjectsResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.projects,
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response.projects
    }

    func getProject(projectId: Int) async throws -> ProjectDetailResponse {
        let response: ProjectDetailResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.project(projectId),
            method: .get,
            body: nil,
            requiresAuth: true
        )
        return response
    }
    
    func createProject(_ project: Project) async throws -> ProjectAPI {
        var deadlineString: String? = nil
        if let deadline = project.deadline {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            deadlineString = df.string(from: deadline)
        }

        let request = CreateProjectRequest(
            name: project.name,
            description: project.description,
            estimatedHours: project.estimatedHours,
            deadline: deadlineString,
            category: project.category,
            color: project.color
        )

        let body = try JSONEncoder().encode(request)

        let response: ProjectResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.projects,
            method: .post,
            body: body,
            requiresAuth: true
        )

        return response.project
    }
    
    struct ProjectDetailResponse: Codable {
        let project: ProjectAPI
        let tasks: [TaskItemAPI]
    }

    func updateProject(_ project: Project) async throws -> ProjectAPI {
        guard let id = project.id else { throw APIError.invalidResponse }

        var deadlineString: String? = nil
        if let deadline = project.deadline {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            deadlineString = df.string(from: deadline)
        }

        let request = UpdateProjectRequest(
            name: project.name,
            description: project.description,
            estimatedHours: Int(project.estimatedHours),
            deadline: deadlineString,
            category: project.category,
            color: project.color
        )

        let body = try JSONEncoder().encode(request)

        let response: ProjectResponse = try await networkManager.request(
            endpoint: APIConfig.Endpoints.project(id),
            method: .put,
            body: body,
            requiresAuth: true
        )

        return response.project
    }

    func deleteProject(projectId: Int) async throws {
        try await networkManager.request(
            endpoint: APIConfig.Endpoints.project(projectId),
            method: .delete,
            body: nil,
            requiresAuth: true
        )
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

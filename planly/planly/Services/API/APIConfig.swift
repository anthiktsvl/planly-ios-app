//
//  APIConfig.swift
//  Planly
//
//  API Configuration
//

import Foundation

struct APIConfig {
    // MARK: - Base URL
    
    /* Debug points to local dev server for fast iteration. Release should point to your deployed API (uncomment + replace when ready). */
    #if DEBUG
    static let baseURL = "http://localhost:3000/api"
    #else
    // static let baseURL = "https://bluhbluhbluh.com/api"
    #endif
    
    // MARK: - Endpoints
    struct Endpoints {
        // Auth
        static let signup = "/auth/signup"
        static let signin = "/auth/signin"
        static let me = "/auth/me"
        static let updateProfile = "/auth/profile"
        
        // Tasks
        static let tasks = "/tasks"
        static func task(_ id: Int) -> String { "/tasks/\(id)" }
        static func tasksByDate(_ date: String) -> String { "/tasks/date/\(date)" }
        static func toggleTask(_ id: Int) -> String { "/tasks/\(id)/toggle" }
        
        // Projects
        static let projects = "/projects"
        static func project(_ id: Int) -> String { "/projects/\(id)" }
        
        // Meetings
        static let meetings = "/meetings"
        static func meeting(_ id: Int) -> String { "/meetings/\(id)" }
        static func meetingsByDate(_ date: String) -> String { "/meetings/date/\(date)" }
        static func cancelMeeting(_ id: Int) -> String { "/meetings/\(id)/cancel" }
        static let availableSlots = "/meetings/available-slots"
    }
}

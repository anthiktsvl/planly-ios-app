//
//  AppDataViewModel.swift
//  Planly
//

import SwiftUI
import Combine

@MainActor
class AppDataViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var projects: [Project] = []
    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    // Computed property for incomplete tasks
    var incompleteTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [TaskItem] {
           tasks.filter { $0.isCompleted }
       }
    
    var todaysMeetings: [Meeting] {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            return meetings.filter { meeting in
                meeting.date >= today && meeting.date < tomorrow
            }
        }
    
    init() {
        print("📱 AppDataViewModel initialized")
        Task {
            await loadAllData()
        }
    }
    
    func loadAllData() async {
        print("🔄 Loading all data...")
        isLoading = true
        await loadTasks()
        await loadProjects()
        await loadMeetings()
        isLoading = false
        print("✅ Finished loading all data")
    }
    
    // MARK: - Tasks
    
   
    
    func loadTasks() async {
        print("📥 Loading tasks from API...")
        do {
            let apiTasks = try await apiService.getTasks()
            print("📦 Received \(apiTasks.count) tasks from API")
            
            // Print the raw response to debug
            print("🔍 Raw API tasks: \(apiTasks)")
            
            tasks = apiTasks.compactMap { apiTask -> TaskItem? in
                // Parse date with ISO8601 formatter (handles .000Z format)
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                guard let taskDate = isoFormatter.date(from: apiTask.date) else {
                    print("❌ Failed to parse date: \(apiTask.date)")
                    return nil
                }
                
                // Parse times if present
                var startTime: Date? = nil
                var endTime: Date? = nil
                
                if let startTimeString = apiTask.startTime {
                    // Try ISO8601 first
                    startTime = isoFormatter.date(from: startTimeString)
                    
                    // Fallback to HH:mm:ss format
                    if startTime == nil {
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "HH:mm:ss"
                        startTime = timeFormatter.date(from: startTimeString)
                    }
                }
                
                if let endTimeString = apiTask.endTime {
                    // Try ISO8601 first
                    endTime = isoFormatter.date(from: endTimeString)
                    
                    // Fallback to HH:mm:ss format
                    if endTime == nil {
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "HH:mm:ss"
                        endTime = timeFormatter.date(from: endTimeString)
                    }
                }
                
                let priority = TaskItem.Priority(rawValue: apiTask.priority.lowercased()) ?? .medium
                
                let task = TaskItem(
                    id: apiTask.id,
                    name: apiTask.name,
                    description: apiTask.description ?? "",
                    category: apiTask.category ?? "",
                    date: taskDate,
                    priority: priority,
                    isCompleted: apiTask.isCompleted,
                    startTime: startTime,
                    endTime: endTime
                )
                
                print("✅ Parsed task: \(task.name) - Date: \(taskDate)")
                return task
            }
            
            print("✅ Loaded \(tasks.count) tasks successfully")
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
            print("❌ Error loading tasks: \(error)")
        }
    }
    
   
    func addTask(_ task: TaskItem) {
        print("➕ Adding task: \(task.name)")
        
        Task {
            do {
                let createdTask = try await apiService.createTask(task)
                print("✅ Task saved to backend with ID: \(createdTask.id ?? 0)")
                
                // Force reload all tasks
                await loadTasks()
                print("✅ Tasks reloaded, count: \(tasks.count)")
            } catch {
                print("❌ Error saving task: \(error)")
                errorMessage = "Failed to save task: \(error.localizedDescription)"
            }
        }
    }
    
    func updateTask(_ task: TaskItem) {
        print("🔄 Updating task: \(task.name)")
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            print("✅ Task updated locally")
        }
        
        Task {
            do {
                if let taskId = task.id {
                    _ = try await apiService.toggleTaskCompletion(taskId: taskId)
                    print("✅ Task updated on backend")
                }
            } catch {
                print("❌ Error updating task: \(error)")
                errorMessage = "Failed to update task"
                await loadTasks()
            }
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        print("🗑️ Deleting task: \(task.name)")
        tasks.removeAll { $0.id == task.id }
        print("✅ Task deleted locally")
        
        Task {
            do {
                if let taskId = task.id {
                    try await apiService.deleteTask(taskId: taskId)
                    print("✅ Task deleted from backend")
                }
            } catch {
                print("❌ Error deleting task: \(error)")
                errorMessage = "Failed to delete task"
                await loadTasks()
            }
        }
    }
    
    // MARK: - Projects
    
    func loadProjects() async {
        print("📥 Loading projects from API...")
        do {
            let apiProjects = try await apiService.getProjects()
            print("📦 Received \(apiProjects.count) projects from API")
            
            projects = apiProjects.compactMap { apiProject -> Project? in
                var deadline: Date? = nil
                if let deadlineString = apiProject.deadline {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    deadline = dateFormatter.date(from: deadlineString)
                }
                
                return Project(
                    id: apiProject.id,
                    name: apiProject.name,
                    description: apiProject.description ?? "",
                    estimatedHours: apiProject.estimatedHours ?? 0,
                    deadline: deadline,
                    category: apiProject.category ?? "",
                    color: apiProject.color ?? "#FFD6E8",
                    tasksCompleted: apiProject.tasksCompleted ?? 0,
                    totalTasks: apiProject.totalTasks ?? 0
                )
            }
            
            print("✅ Loaded \(projects.count) projects successfully")
        } catch {
            errorMessage = "Failed to load projects: \(error.localizedDescription)"
            print("❌ Error loading projects: \(error)")
        }
    }
    
    func addProject(_ project: Project) {
        print("➕ Adding project: \(project.name)")
        projects.append(project)
        
        Task {
            do {
                _ = try await apiService.createProject(project)
                print("✅ Project saved to backend")
                await loadProjects()
            } catch {
                errorMessage = "Failed to save project: \(error.localizedDescription)"
                print("❌ Error saving project: \(error)")
                projects.removeAll { $0.id == project.id }
            }
        }
    }
    
    func deleteProject(_ project: Project) {
        print("🗑️ Deleting project: \(project.name)")
        projects.removeAll { $0.id == project.id }
        print("✅ Project deleted locally")
    }
    
    // MARK: - Meetings
    
    func loadMeetings() async {
        print("📥 Loading meetings from API...")
        do {
            let apiMeetings = try await apiService.getMeetings()
            print("📦 Received \(apiMeetings.count) meetings from API")
            
            meetings = apiMeetings.compactMap { apiMeeting -> Meeting? in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatter.date(from: apiMeeting.date) else {
                    print("❌ Failed to parse date: \(apiMeeting.date)")
                    return nil
                }
                
                let isoFormatter = ISO8601DateFormatter()
                guard let startTime = isoFormatter.date(from: apiMeeting.startTime),
                      let endTime = isoFormatter.date(from: apiMeeting.endTime) else {
                    print("❌ Failed to parse times")
                    return nil
                }
                
                // Parse status - default to pending if invalid
                // let status = Meeting.MeetingStatus(rawValue: apiMeeting.status ?? "pending") ?? .pending
                
                return Meeting(
                    id: apiMeeting.id,
                    title: apiMeeting.title,
                    description: apiMeeting.description ?? "",
                    date: date,
                    startTime: startTime,
                    endTime: endTime,
                    attendeeEmail: apiMeeting.attendeeEmail,
                    status: apiMeeting.status
                )
            }
            
            print("✅ Loaded \(meetings.count) meetings successfully")
        } catch {
            errorMessage = "Failed to load meetings: \(error.localizedDescription)"
            print("❌ Error loading meetings: \(error)")
        }
    }
}

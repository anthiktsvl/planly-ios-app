//
//  TasksView.swift
//  Planly
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false
    @State private var searchText = ""
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case completed = "Completed"
    }
    
    var filteredTasks: [TaskItem] {
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        var tasks = dataViewModel.tasks
        
        // Apply search filter
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.name.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            return tasks
        case .today:
            return tasks.filter { task in
                task.date >= startOfToday && task.date < endOfToday
            }
        case .upcoming:
            return tasks.filter { task in
                task.date >= endOfToday && !task.isCompleted
            }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search tasks...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    // Tasks List
                    if filteredTasks.isEmpty {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: getEmptyStateIcon())
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text(getEmptyStateTitle())
                                .adaptiveFont(.title2, weight: .semibold)
                            
                            Text(getEmptyStateMessage())
                                .adaptiveFont(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            if selectedFilter == .all && searchText.isEmpty {
                                Button {
                                    showingAddTask = true
                                } label: {
                                    Text("Create Task")
                                        .adaptiveFont(.subheadline, weight: .semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    ColorTheme.primary(for: themeManager.currentTheme),
                                                    ColorTheme.dark(for: themeManager.currentTheme)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTasks) { task in
                                    TaskRowView(task: task)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    private func getEmptyStateIcon() -> String {
        switch selectedFilter {
        case .all:
            return "checkmark.circle"
        case .today:
            return "calendar"
        case .upcoming:
            return "clock"
        case .completed:
            return "checkmark.seal"
        }
    }
    
    private func getEmptyStateTitle() -> String {
        switch selectedFilter {
        case .all:
            return "No Tasks Yet"
        case .today:
            return "No Tasks Today"
        case .upcoming:
            return "No Upcoming Tasks"
        case .completed:
            return "No Completed Tasks"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        if !searchText.isEmpty {
            return "No tasks match '\(searchText)'"
        }
        
        switch selectedFilter {
        case .all:
            return "Create a task to get started"
        case .today:
            return "You're all clear for today!"
        case .upcoming:
            return "No tasks scheduled for later"
        case .completed:
            return "Complete some tasks to see them here"
        }
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    let task: TaskItem
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button {
                var updatedTask = task
                updatedTask.isCompleted.toggle()
                dataViewModel.updateTask(updatedTask)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? ColorTheme.primary(for: themeManager.currentTheme) : ColorTheme.dark(for: themeManager.currentTheme))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .adaptiveFont(.subheadline, weight: .semibold)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(task.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .adaptiveFont(.caption2)
                        .foregroundColor(.secondary)
                    
                    if !task.category.isEmpty {
                        Label(task.category, systemImage: "tag")
                            .adaptiveFont(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Priority Indicator
            Circle()
                .fill(task.priority.color)
                .frame(width: 8, height: 8)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(task: task)
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}

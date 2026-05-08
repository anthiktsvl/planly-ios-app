//
//  EditTaskView.swift
//  planly-app
//
//  Created by Anthi Koutsouveli on 18/01/2026.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel
    
    let task: TaskItem
    
    @State private var taskName: String
    @State private var taskDescription: String
    @State private var date: Date
    @State private var hasStartTime: Bool
    @State private var startTime: Date
    @State private var hasEndTime: Bool
    @State private var endTime: Date
    @State private var priority: TaskItem.Priority
    @State private var category: String
    @State private var selectedProjectId: Int? = nil
    
    init(task: TaskItem) {
        self.task = task
        _taskName = State(initialValue: task.name)
        _taskDescription = State(initialValue: task.description)
        _date = State(initialValue: task.date)
        _hasStartTime = State(initialValue: task.startTime != nil)
        _startTime = State(initialValue: task.startTime ?? Date())
        _hasEndTime = State(initialValue: task.endTime != nil)
        _endTime = State(initialValue: task.endTime ?? Date())
        _priority = State(initialValue: task.priority)
        _category = State(initialValue: task.category)
        _selectedProjectId = State(initialValue: task.projectId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $taskName)
                    
                    TextField("Description (Optional)", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Category (Optional)", text: $category)
                }
                
                Section("Date & Time") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("Start Time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("End Time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Priority") {
                    Picker("Priority Level", selection: $priority) {
                        ForEach([TaskItem.Priority.low, .medium, .high], id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue.capitalized)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(role: .destructive) {
                        dataViewModel.deleteTask(task)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Delete Task", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
                Section("Project") {
                    Picker("Project", selection: Binding(
                        get: { selectedProjectId ?? -1 },
                        set: { newValue in selectedProjectId = (newValue == -1 ? nil : newValue) }
                    )) {
                        Text("None").tag(-1)

                        ForEach(dataViewModel.projects) { project in
                            Text(project.name).tag(project.id ?? -1)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateTask()
                    }
                    .disabled(taskName.isEmpty)
                }
            }
        }
    }
    
    private func updateTask() {
        let updatedTask = TaskItem(
            id: task.id,
            name: taskName,
            description: taskDescription,
            category: category,
            date: date,
            priority: priority,
            isCompleted: task.isCompleted,
            startTime: hasStartTime ? startTime : nil,
            endTime: hasEndTime ? endTime : nil,
            projectId: selectedProjectId    
        )

        dataViewModel.updateTask(updatedTask)
        dismiss()
    }
}


#Preview {
    EditTaskView(task: TaskItem(
        id: 1,
        name: "Sample Task",
        description: "This is a sample",
        category: "Work",
        date: Date(),
        priority: .medium,
        isCompleted: false,
        startTime: nil,
        endTime: nil
    ))
    .environmentObject(AppDataViewModel())
}

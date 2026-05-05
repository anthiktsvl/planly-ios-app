//
//  AddTaskView.swift
//  Planly
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel

    let selectedDate: Date

    @State private var taskName = ""
    @State private var date: Date

    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
        _date = State(initialValue: selectedDate)
    }

    @State private var taskDescription = ""
    @State private var hasStartTime = false
    @State private var startTime = Date()
    @State private var hasEndTime = false
    @State private var endTime = Date()
    @State private var priority: TaskItem.Priority = .medium
    @State private var category = ""

    // ✅ NEW: selected project
    @State private var selectedProjectId: Int? = nil

    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $taskName)
                    TextField("Description", text: $taskDescription)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                // ✅ NEW: Project selection
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

                Section("Time") {
                    Toggle("Set Start Time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    }

                    Toggle("Set End Time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    TextField("Category (e.g., Work, Personal)", text: $category)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createTask() }
                        .disabled(taskName.isEmpty)
                }
            }
        }
    }

    private func createTask() {
        let newTask = TaskItem(
            id: nil,
            name: taskName,
            description: taskDescription,
            category: category,
            date: date,
            priority: priority,
            isCompleted: false,
            startTime: hasStartTime ? startTime : nil,
            endTime: hasEndTime ? endTime : nil,
            projectId: selectedProjectId // ✅ NEW
        )

        dataViewModel.addTask(newTask)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(AppDataViewModel())
}

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
    //@State private var subtasks: [Subtask] = []
    @State private var newSubtaskName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $taskName)
                    TextField("Description", text: $taskDescription)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
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
                
//                Section("Subtasks") {
//                    ForEach(subtasks) { subtask in
//                        Text(subtask.name)
//                    }
//                    
//                    HStack {
//                        TextField("Add Subtask", text: $newSubtaskName)
//                        Button("Add") {
//                            if !newSubtaskName.isEmpty {
//                                subtasks.append(Subtask(name: newSubtaskName))
//                                newSubtaskName = ""
//                            }
//                        }
//                    }
//                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTask()
                    }
                    .disabled(taskName.isEmpty)
                }
            }
        }
    }
    
    private func createTask() {
        print("🚨🚨🚨 CREATE TASK BUTTON PRESSED! 🚨🚨🚨")
        let newTask = TaskItem(
            id: nil, 
            name: taskName,
            description: taskDescription,
            category: category,
            date: date,
            priority: priority,
            isCompleted: false,
            startTime: nil,
            endTime: nil
        )
        
        print("🚨 Task object created: \(newTask.name)")
          print("🚨 Calling dataViewModel.addTask...")
          
          dataViewModel.addTask(newTask)
          
          print("🚨 Dismissing sheet...")
          dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(AppDataViewModel())
}

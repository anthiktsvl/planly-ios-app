//
//  AddProjectView.swift
//  Planly
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel
    
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var estimatedHours = 1
    @State private var category = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    
                    TextField("Description (Optional)", text: $projectDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Category (Optional)", text: $category)
                }
                
                Section("Timeline") {
                    Stepper("Estimated Hours: \(estimatedHours)", value: $estimatedHours, in: 1...200)
                    
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        createProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
    
    private func createProject() {
        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🟣 createProject tapped. name='\(trimmedName)' estimatedHours=\(estimatedHours)")

        let newProject = Project(
            id: nil,
            name: trimmedName,
            description: projectDescription,
            estimatedHours: Double(max(1, estimatedHours)),
            deadline: hasDeadline ? deadline : nil,
            category: category,
            color: "#FFD6E8",
            tasksCompleted: 0,
            totalTasks: 0
        )

        print("🟣 calling dataViewModel.addProject(...)")
        dataViewModel.addProject(newProject)
        dismiss()
    }
}

#Preview {
    AddProjectView()
        .environmentObject(AppDataViewModel())
}

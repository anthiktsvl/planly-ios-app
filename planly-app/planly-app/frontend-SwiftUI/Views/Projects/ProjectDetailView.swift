import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var project: Project
    @State private var projectTasks: [TaskItem] = []
    @State private var isLoadingTasks = false
    @State private var tasksError: String?

    @State private var name: String
    @State private var description: String
    @State private var estimatedHours: Int
    @State private var category: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var color: String

    init(project: Project) {
        _project = State(initialValue: project)
        _name = State(initialValue: project.name)
        _description = State(initialValue: project.description)
        _estimatedHours = State(initialValue: max(1, project.estimatedHours))
        _category = State(initialValue: project.category)
        _hasDeadline = State(initialValue: project.deadline != nil)
        _deadline = State(initialValue: project.deadline ?? Date())
        _color = State(initialValue: project.color)
    }

    var body: some View {
        Form {
            Section("Tasks") {
                if isLoadingTasks {
                    ProgressView()
                } else if let tasksError {
                    Text(tasksError).foregroundStyle(.red)
                } else if projectTasks.isEmpty {
                    Text("No tasks in this project yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(projectTasks) { task in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.name)
                                    .font(.headline)

                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompleted ? .green : .secondary)
                        }
                    }
                }
            }

            Section("Project Details") {
                TextField("Project Name", text: $name)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Category", text: $category)
            }

            Section("Timeline") {
                Stepper("Estimated Hours: \(estimatedHours)", value: $estimatedHours, in: 1...200)

                Toggle("Set Deadline", isOn: $hasDeadline)
                if hasDeadline {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }

            Section("Appearance") {
                TextField("Color (hex)", text: $color)
            }

            Section {
                Button("Save Changes") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section {
                Button("Delete Project", role: .destructive) { delete() }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProjectTasks()
        }
    }

    private func loadProjectTasks() async {
        guard let id = project.id else { return }
        isLoadingTasks = true
        tasksError = nil

        do {
            let detail = try await APIService.shared.getProject(projectId: id)

            // Convert TaskItemAPI -> TaskItem (same logic as loadTasks)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            projectTasks = detail.tasks.compactMap { apiTask in
                guard let taskDate = iso.date(from: apiTask.date) ?? ISO8601DateFormatter().date(from: apiTask.date) else {
                    return nil
                }

                let priority = TaskItem.Priority(rawValue: apiTask.priority.lowercased()) ?? .medium

                return TaskItem(
                    id: apiTask.id,
                    name: apiTask.name,
                    description: apiTask.description ?? "",
                    category: apiTask.category ?? "",
                    date: taskDate,
                    priority: priority,
                    isCompleted: apiTask.isCompleted,
                    startTime: nil,
                    endTime: nil,
                    projectId: apiTask.projectId
                )
            }
        } catch {
            tasksError = "Failed to load tasks: \(error.localizedDescription)"
        }

        isLoadingTasks = false
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        project.name = trimmed
        project.description = description
        project.estimatedHours = max(1, estimatedHours)
        project.category = category
        project.deadline = hasDeadline ? deadline : nil
        project.color = color.isEmpty ? "#FFD6E8" : color

        dataViewModel.updateProject(project)
        dismiss()
    }

    private func delete() {
        dataViewModel.deleteProject(project)
        dismiss()
    }
}

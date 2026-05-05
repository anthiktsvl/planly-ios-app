//
//  ProjectsView.swift
//  Planly
//

import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var fontManager: FontManager
    @State private var showingAddProject = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if dataViewModel.projects.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))

                        Text("No Projects Yet")
                            .adaptiveFont(.title2, weight: .semibold)

                        Text("Create a project to organize your tasks")
                            .adaptiveFont(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button {
                            showingAddProject = true
                        } label: {
                            Text("Create Project")
                                .adaptiveFont(.subheadline, weight: .semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    // Projects List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(dataViewModel.projects) { project in
                                NavigationLink {
                                    ProjectDetailView(project: project)
                                } label: {
                                    ProjectCard(project: project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
            }
        }
    }
}

struct ProjectCard: View {
    @EnvironmentObject var fontManager: FontManager
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .adaptiveFont(.headline, weight: .bold)

                    if !project.description.isEmpty {
                        Text(project.description)
                            .adaptiveFont(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                if let deadline = project.deadline {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Due")
                            .adaptiveFont(.caption2)
                            .foregroundColor(.secondary)
                        Text(deadline.formatted(date: .abbreviated, time: .omitted))
                            .adaptiveFont(.caption, weight: .semibold)
                    }
                }
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(project.tasksCompleted)/\(project.totalTasks) tasks")
                        .adaptiveFont(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(project.progress * 100))%")
                        .adaptiveFont(.caption2, weight: .semibold)
                        .foregroundColor(.pink)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * project.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }

            // Metadata
            HStack(spacing: 16) {
                Label("\(project.estimatedHours)h", systemImage: "clock")
                    .adaptiveFont(.caption2)
                    .foregroundColor(.secondary)

                if !project.category.isEmpty {
                    Label(project.category, systemImage: "tag")
                        .adaptiveFont(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ProjectsView()
        .environmentObject(AppDataViewModel())
        .environmentObject(FontManager())
}

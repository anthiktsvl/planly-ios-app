//
//  TemplatesView.swift
//  Planly
//

import SwiftUI

struct TemplatesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @State private var selectedCategory: TemplateCategory = .all
    @State private var showingTemplateDetail = false
    @State private var selectedTemplate: Any?
    
    enum TemplateCategory: String, CaseIterable {
        case all = "All"
        case project = "Projects"
        case task = "Tasks"
        case meeting = "Meetings"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Category Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(TemplateCategory.allCases, id: \.self) { category in
                                    CategoryPill(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Project Templates
                        if selectedCategory == .all || selectedCategory == .project {
                            TemplateSectionView(title: "Project Templates", icon: "folder.fill", color: .purple) {
                                ForEach(TemplateData.projectTemplates) { template in
                                    ProjectTemplateCard(template: template) {
                                        createProjectFrom(template)
                                    }
                                }
                            }
                        }
                        
                        // Task Templates
                        if selectedCategory == .all || selectedCategory == .task {
                            TemplateSectionView(title: "Task Templates", icon: "checkmark.circle.fill", color: .blue) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(TemplateData.taskTemplates) { template in
                                        TaskTemplateCard(template: template) {
                                            createTaskFrom(template)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Meeting Templates
                        if selectedCategory == .all || selectedCategory == .meeting {
                            TemplateSectionView(title: "Meeting Templates", icon: "video.fill", color: .orange) {
                                ForEach(TemplateData.meetingTemplates) { template in
                                    MeetingTemplateCard(template: template) {
                                        createMeetingFrom(template)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func createProjectFrom(_ template: ProjectTemplate) {
        // TODO: Create project with tasks from template
        dismiss()
    }
    
    private func createTaskFrom(_ template: TaskTemplate) {
        // TODO: Create task from template
        dismiss()
    }
    
    private func createMeetingFrom(_ template: MeetingTemplate) {
        // TODO: Create meeting from template
        dismiss()
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ).opacity(1) :
                    LinearGradient(colors: [Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: isSelected ? ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Template Section
struct TemplateSectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            content
                .padding(.horizontal)
        }
    }
}

// MARK: - Project Template Card
struct ProjectTemplateCard: View {
    let template: ProjectTemplate
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundColor(colorFor(template.color))
                    
                    Spacer()
                    
                    Text("\(template.taskTemplates.count) tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                    Text(template.category)
                        .font(.caption)
                }
                .foregroundColor(colorFor(template.color))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(colorFor(template.color).opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    func colorFor(_ name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return ColorTheme.primary(for: themeManager.currentTheme)
        }
    }
}

// MARK: - Task Template Card
struct TaskTemplateCard: View {
    let template: TaskTemplate
    let action: () -> Void
    
    var priorityColor: Color {
        switch template.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.system(size: 30))
                    .foregroundColor(priorityColor)
                    .frame(height: 40)
                
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let duration = template.estimatedDuration {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("\(duration)m")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(priorityColor.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Meeting Template Card
struct MeetingTemplateCard: View {
    let template: MeetingTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: template.icon)
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text("\(template.defaultDuration) min")
                            .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(template.agendaItems.count) items")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Template Data
struct TemplateData {
    static let projectTemplates: [ProjectTemplate] = [
        ProjectTemplate(
            id: 1,
            name: "Website Launch",
            description: "Complete project template for launching a new website",
            category: "Development",
            color: "blue",
            taskTemplates: [],
            icon: "globe"
        ),
        ProjectTemplate(
            id: 2,
            name: "Marketing Campaign",
            description: "Run a successful marketing campaign from start to finish",
            category: "Marketing",
            color: "purple",
            taskTemplates: [],
            icon: "megaphone.fill"
        ),
        ProjectTemplate(
            id: 3,
            name: "Event Planning",
            description: "Organize and execute a successful event",
            category: "Events",
            color: "orange",
            taskTemplates: [],
            icon: "calendar.badge.plus"
        )
    ]
    
    static let taskTemplates: [TaskTemplate] = [
        TaskTemplate(id: 1, name: "Quick Email", description: "", category: "Communication", priority: .low, estimatedDuration: 5, icon: "envelope.fill"),
        TaskTemplate(id: 2, name: "Code Review", description: "", category: "Development", priority: .medium, estimatedDuration: 30, icon: "doc.text.magnifyingglass"),
        TaskTemplate(id: 3, name: "Client Call", description: "", category: "Communication", priority: .high, estimatedDuration: 45, icon: "phone.fill"),
        TaskTemplate(id: 4, name: "Write Blog Post", description: "", category: "Content", priority: .medium, estimatedDuration: 120, icon: "text.book.closed.fill"),
        TaskTemplate(id: 5, name: "Team Sync", description: "", category: "Meeting", priority: .medium, estimatedDuration: 30, icon: "person.3.fill"),
        TaskTemplate(id: 6, name: "Bug Fix", description: "", category: "Development", priority: .high, estimatedDuration: 60, icon: "ant.fill")
    ]
    
    static let meetingTemplates: [MeetingTemplate] = [
        MeetingTemplate(
            id: 1,
            name: "Daily Standup",
            description: "Quick team sync",
            defaultDuration: 15,
            agendaItems: ["Yesterday's progress", "Today's goals", "Blockers"],
            icon: "person.2.fill"
        ),
        MeetingTemplate(
            id: 2,
            name: "Weekly Planning",
            description: "Plan the week ahead",
            defaultDuration: 60,
            agendaItems: ["Last week review", "Priorities", "Resource allocation", "Goals"],
            icon: "calendar"
        ),
        MeetingTemplate(
            id: 3,
            name: "Client Presentation",
            description: "Present to client",
            defaultDuration: 45,
            agendaItems: ["Introduction", "Progress update", "Demo", "Q&A", "Next steps"],
            icon: "person.wave.2.fill"
        ),
        MeetingTemplate(
            id: 4,
            name: "1-on-1",
            description: "One-on-one meeting",
            defaultDuration: 30,
            agendaItems: ["Check-in", "Feedback", "Career growth", "Action items"],
            icon: "person.crop.circle.fill"
        )
    ]
}

#Preview {
    TemplatesView()
        .environmentObject(ThemeManager())
        .environmentObject(AppDataViewModel())
}

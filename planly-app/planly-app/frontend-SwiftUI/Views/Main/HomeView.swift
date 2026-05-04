//
//  HomeView.swift
//  Planly
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User greeting
                    if let user = authViewModel.currentUser {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello,")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(user.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    // Today's stats
                    HStack(spacing: 16) {
                        StatCard(
                            icon: "checkmark.circle",
                            title: "Tasks",
                            value: "\(dataViewModel.incompleteTasks.count)",
                            color: .pink
                        )
                        
                        StatCard(
                            icon: "folder",
                            title: "Projects",
                            value: "\(dataViewModel.projects.count)",
                            color: .purple
                        )
                        
                        StatCard(
                            icon: "person.2",
                            title: "Meetings",
                            value: "\(dataViewModel.todaysMeetings.count)",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    // Upcoming tasks
                    if !dataViewModel.incompleteTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming Tasks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(dataViewModel.incompleteTasks.prefix(5)) { task in
                                TaskRowView(task: task)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Today's meetings
                    if !dataViewModel.todaysMeetings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Meetings")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(dataViewModel.todaysMeetings) { meeting in
                                MeetingRowView(meeting: meeting)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
        }
    }
}


// MARK: - Meeting Row View
struct MeetingRowView: View {
    let meeting: Meeting
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "video.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(meeting.startTime.formatted(date: .omitted, time: .shortened)) - \(meeting.endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppDataViewModel())
        .environmentObject(AuthViewModel())
}

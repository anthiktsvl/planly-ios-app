//
//  MeetingsView.swift
//  Planly
//
//  View for managing meetings
//

import SwiftUI

struct MeetingsView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var showingAddMeeting = false
    @State private var selectedFilter: MeetingFilter = .upcoming
    
    enum MeetingFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case today = "Today"
        case all = "All"
    }
    
    var filteredMeetings: [Meeting] {
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        switch selectedFilter {
        case .upcoming:
            return dataViewModel.meetings.filter { $0.startTime > now }.sorted { $0.startTime < $1.startTime }
        case .today:
            return dataViewModel.meetings.filter { 
                $0.date >= startOfToday && $0.date < endOfToday 
            }.sorted { $0.startTime < $1.startTime }
        case .all:
            return dataViewModel.meetings.sorted { $0.startTime < $1.startTime }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(MeetingFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color(.systemBackground))
                    
                    if filteredMeetings.isEmpty {
                        EmptyMeetingsView(filter: selectedFilter)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredMeetings) { meeting in
                                    MeetingCard(meeting: meeting)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Meetings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMeeting = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ColorTheme.primary(for: themeManager.currentTheme),
                                        ColorTheme.dark(for: themeManager.currentTheme)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddMeeting) {
                AddMeetingView()
            }
        }
    }
}

// MARK: - Meeting Card
struct MeetingCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var dataViewModel: AppDataViewModel
    let meeting: Meeting
    @State private var showingDeleteAlert = false
    
    var isUpcoming: Bool {
        meeting.startTime > Date()
    }
    
    var isPast: Bool {
        meeting.endTime < Date()
    }
    
    var statusColor: Color {
        if let status = meeting.status?.lowercased() {
            if status == "cancelled" {
                return .red
            }
        }
        if isPast {
            return .gray
        }
        return .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "video.circle.fill")
                    .font(.title2)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meeting.title)
                        .adaptiveFont(.headline, weight: .bold)
                    
                    if let status = meeting.status {
                        Text(status.capitalized)
                            .adaptiveFont(.caption2, weight: .semibold)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Delete button
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Description
            if !meeting.description.isEmpty {
                Text(meeting.description)
                    .adaptiveFont(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(meeting.date.formatted(date: .abbreviated, time: .omitted))
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(meeting.startTime.formatted(date: .omitted, time: .shortened)) - \(meeting.endTime.formatted(date: .omitted, time: .shortened))")
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "person.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(meeting.attendeeEmail)
                        .adaptiveFont(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .alert("Delete Meeting", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataViewModel.deleteMeeting(meeting)
            }
        } message: {
            Text("Are you sure you want to delete '\(meeting.title)'?")
        }
    }
}

// MARK: - Empty State
struct EmptyMeetingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let filter: MeetingsView.MeetingFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ColorTheme.primary(for: themeManager.currentTheme),
                            ColorTheme.dark(for: themeManager.currentTheme)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding()
            
            VStack(spacing: 8) {
                Text("No \(filter.rawValue) Meetings")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Tap the + button to schedule a meeting")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add Meeting View
struct AddMeetingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var attendeeEmail = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meeting Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Date & Time") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section("Attendee") {
                    TextField("Email", text: $attendeeEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("New Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeeting()
                    }
                    .disabled(title.isEmpty || attendeeEmail.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                ColorTheme.primary(for: themeManager.currentTheme),
                                ColorTheme.dark(for: themeManager.currentTheme)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
        }
    }
    
    private func saveMeeting() {
        let newMeeting = Meeting(
            id: nil,
            title: title,
            description: description,
            date: date,
            startTime: startTime,
            endTime: endTime,
            attendeeEmail: attendeeEmail,
            status: "scheduled"
        )
        
        dataViewModel.addMeeting(newMeeting)
        dismiss()
    }
}

#Preview {
    MeetingsView()
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}

//
//  MeetingsView.swift
//  Planly
//
//  Overview of all meetings
//

import SwiftUI

struct MeetingsView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var showingAddMeeting = false
    @State private var selectedFilter: MeetingFilter = .all
    
    enum MeetingFilter: String, CaseIterable {
        case all = "All"
        case upcoming = "Upcoming"
        case past = "Past"
    }
    
    var filteredMeetings: [Meeting] {
        let now = Date()
        switch selectedFilter {
        case .all:
            return dataViewModel.meetings.sorted { $0.startTime < $1.startTime }
        case .upcoming:
            return dataViewModel.meetings.filter { $0.startTime >= now }.sorted { $0.startTime < $1.startTime }
        case .past:
            return dataViewModel.meetings.filter { $0.startTime < now }.sorted { $0.startTime > $1.startTime }
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
                    
                    // Meetings List
                    if filteredMeetings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.clock")
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
                            
                            Text("No \(selectedFilter.rawValue.lowercased()) meetings")
                                .adaptiveFont(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Schedule a meeting to get started")
                                .adaptiveFont(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
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
                            .font(.title2)
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
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    let meeting: Meeting
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var isPast: Bool {
        meeting.endTime < Date()
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(meeting.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Meeting icon with status
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isPast ? 
                                    [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] :
                                    [ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2), ColorTheme.light(for: themeManager.currentTheme).opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isPast ? "checkmark.circle.fill" : "video.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: isPast ?
                                    [Color.gray, Color.gray.opacity(0.7)] :
                                    [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meeting.title)
                        .adaptiveFont(.headline)
                        .foregroundColor(isPast ? .secondary : .primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(meeting.startTime.formatted(date: .omitted, time: .shortened)) - \(meeting.endTime.formatted(date: .omitted, time: .shortened))")
                            .adaptiveFont(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Today badge
                if isToday && !isPast {
                    Text("Today")
                        .adaptiveFont(.caption2, weight: .bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
            }
            
            // Date
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(meeting.date.formatted(date: .abbreviated, time: .omitted))
                    .adaptiveFont(.caption)
            }
            .foregroundColor(.secondary)
            
            // Description
            if !meeting.description.isEmpty {
                Text(meeting.description)
                    .adaptiveFont(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            // Attendee
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(ColorTheme.primary(for: themeManager.currentTheme))
                
                Text(meeting.attendeeEmail)
                    .adaptiveFont(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Actions
                HStack(spacing: 16) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(ColorTheme.primary(for: themeManager.currentTheme))
                    }
                    
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(
            color: isPast ? .black.opacity(0.03) : ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .opacity(isPast ? 0.7 : 1.0)
        .sheet(isPresented: $showingEditSheet) {
            EditMeetingView(meeting: meeting)
        }
        .alert("Delete Meeting", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let id = meeting.id {
                    dataViewModel.deleteMeeting(id: id)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(meeting.title)'?")
        }
    }
}

// MARK: - Add Meeting View
struct AddMeetingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // 1 hour later
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
                
                Section("Attendees") {
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
                    Button("Add") {
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
}

// MARK: - Edit Meeting View
struct EditMeetingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    
    let meeting: Meeting
    
    @State private var title: String
    @State private var description: String
    @State private var date: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var attendeeEmail: String
    
    init(meeting: Meeting) {
        self.meeting = meeting
        _title = State(initialValue: meeting.title)
        _description = State(initialValue: meeting.description)
        _date = State(initialValue: meeting.date)
        _startTime = State(initialValue: meeting.startTime)
        _endTime = State(initialValue: meeting.endTime)
        _attendeeEmail = State(initialValue: meeting.attendeeEmail)
    }
    
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
                
                Section("Attendees") {
                    TextField("Email", text: $attendeeEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Edit Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedMeeting = meeting
                        updatedMeeting.title = title
                        updatedMeeting.description = description
                        updatedMeeting.date = date
                        updatedMeeting.startTime = startTime
                        updatedMeeting.endTime = endTime
                        updatedMeeting.attendeeEmail = attendeeEmail
                        dataViewModel.updateMeeting(updatedMeeting)
                        dismiss()
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
}

#Preview {
    MeetingsView()
        .environmentObject(AppDataViewModel())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager())
}

//
//  CalendarView.swift
//  Planly
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var tasksForSelectedDate: [TaskItem] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return dataViewModel.tasks.filter { task in
            task.date >= startOfDay && task.date < endOfDay
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Month Header
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.pink)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(ColorTheme.babyPinkDark)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    
                    // Days of Week Header
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    
                    // Calendar Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                        ForEach(getDaysInMonth(), id: \.self) { date in
                            if let date = date {
                                DayCell(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    hasTask: hasTaskOnDate(date)
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedDate = date
                                    }
                                }
                            } else {
                                Color.clear
                                    .frame(height: 50)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .background(Color(.systemBackground))
                    
                    // Tasks Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorTheme.babyPink)
                            Text("Tasks")
                                .font(.headline)
                            Text("(\(tasksForSelectedDate.count))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        if tasksForSelectedDate.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("No tasks for this day")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(tasksForSelectedDate) { task in
                                        CalendarTaskRow(task: task)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        // Get all days for the calendar grid (6 weeks max)
        for _ in 0..<42 {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func hasTaskOnDate(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return dataViewModel.tasks.contains { task in
            task.date >= startOfDay && task.date < endOfDay
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTask: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(
                        isSelected ? .black :
                        isToday ? ColorTheme.babyPinkLight :
                        .primary
                    )
                
                if hasTask {
                    Circle()
                        .fill(isSelected ? Color.black : ColorTheme.babyPink)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [ColorTheme.babyPinkLight, ColorTheme.babyPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else if isToday {
                        ColorTheme.babyPinkDark.opacity(0.1)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isSelected ? Color.pink : Color.clear, lineWidth: 1)
            )
        }
        .padding(2)
    }
}

// MARK: - Calendar Task Row
struct CalendarTaskRow: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel
    let task: TaskItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button {
                var updatedTask = task
                updatedTask.isCompleted.toggle()
                dataViewModel.updateTask(updatedTask)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : priorityColor)
            }
            
            // Priority Bar
            RoundedRectangle(cornerRadius: 2)
                .fill(priorityColor)
                .frame(width: 3, height: 40)
            
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Priority Badge
            Text(task.priority.rawValue.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(priorityColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(priorityColor.opacity(0.15))
                .cornerRadius(6)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppDataViewModel())
}

//
//  NotesView.swift
//  Planly
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var notes: [Note] = []
    @State private var searchText = ""
    @State private var showingEditNote = false
    @State private var selectedNote: Note?
    @State private var isLoading = false
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes.sorted { note1, note2 in
                if note1.isPinned == note2.isPinned {
                    return note1.updatedAt > note2.updatedAt
                }
                return note1.isPinned && !note2.isPinned
            }
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }.sorted { note1, note2 in
            if note1.isPinned == note2.isPinned {
                return note1.updatedAt > note2.updatedAt
            }
            return note1.isPinned && !note2.isPinned
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if notes.isEmpty && !isLoading {
                    EmptyNotesView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredNotes) { note in
                                NoteCard(note: note) {
                                    selectedNote = note
                                    showingEditNote = true
                                }
                                .contextMenu {
                                    Button {
                                        togglePin(note)
                                    } label: {
                                        Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                                    }
                                    
                                    Button(role: .destructive) {
                                        deleteNote(note)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 80) // Space for FAB
                    }
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search notes")
            .sheet(isPresented: $showingEditNote) {
                if let note = selectedNote {
                    EditNoteView(note: note) { updatedNote in
                        updateNote(updatedNote)
                    }
                }
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    private func loadNotes() {
        isLoading = true
        // TODO: Load from API
        // For now, load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "savedNotes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
        isLoading = false
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    private func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    private func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func togglePin(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isPinned.toggle()
            saveNotes()
        }
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: Note
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var noteColor: Color {
        switch note.color.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        default: return ColorTheme.primary(for: themeManager.currentTheme)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(noteColor)
                    }
                    
                    if !note.title.isEmpty {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(note.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(noteColor.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: noteColor.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Notes View
struct EmptyNotesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Notes Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Tap the + button to create your first quick note")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

// MARK: - Edit Note View
struct EditNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var note: Note
    @State private var title: String
    @State private var content: String
    @State private var selectedColor: String
    let onSave: (Note) -> Void
    
    let colors = ["blue", "green", "yellow", "orange", "red", "purple", "pink"]
    
    init(note: Note, onSave: @escaping (Note) -> Void) {
        self._note = State(initialValue: note)
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
        self._selectedColor = State(initialValue: note.color)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Title")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Note title (optional)", text: $title)
                                .font(.headline)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $content)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(colors, id: \.self) { color in
                                        ColorCircle(
                                            color: color,
                                            isSelected: selectedColor == color
                                        ) {
                                            selectedColor = color
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedNote = note
                        updatedNote.title = title
                        updatedNote.content = content
                        updatedNote.color = selectedColor
                        updatedNote.updatedAt = Date()
                        onSave(updatedNote)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Color Circle
struct ColorCircle: View {
    let color: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var colorValue: Color {
        switch color.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(colorValue)
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    NotesView()
        .environmentObject(ThemeManager())
}

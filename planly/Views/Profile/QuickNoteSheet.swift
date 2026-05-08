//
//  QuickNoteSheet.swift
//  Planly
//

import SwiftUI

struct QuickNoteSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var content: String = ""
    @State private var title: String = ""
    @State private var selectedColor: String = "blue"
    let onSave: (Note) -> Void
    
    let colors = ["blue", "green", "yellow", "orange", "red", "purple", "pink"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Quick illustration
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
                    Text("Quick Note")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 16) {
                        // Title field
                        TextField("Title (optional)", text: $title)
                            .font(.headline)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Content field
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("What's on your mind?")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                            }
                            
                            TextEditor(text: $content)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose a color")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(colors, id: \.self) { color in
                                        QuickColorCircle(
                                            color: color,
                                            isSelected: selectedColor == color
                                        ) {
                                            selectedColor = color
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save button
                    Button {
                        saveNote()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Note")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [ColorTheme.primary(for: themeManager.currentTheme), ColorTheme.dark(for: themeManager.currentTheme)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(content.isEmpty)
                    .opacity(content.isEmpty ? 0.6 : 1)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func saveNote() {
        let newNote = Note(
            id: Int.random(in: 1000...999999), // Temporary ID until backend assigns one
            title: title,
            content: content,
            createdAt: Date(),
            updatedAt: Date(),
            color: selectedColor,
            isPinned: false
        )
        onSave(newNote)
        dismiss()
    }
}

// MARK: - Quick Color Circle
struct QuickColorCircle: View {
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
                    .frame(width: 40, height: 40)
                
                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .strokeBorder(colorValue, lineWidth: 2)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    QuickNoteSheet { _ in }
        .environmentObject(ThemeManager())
}

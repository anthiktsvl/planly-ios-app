import SwiftUI

struct FilterChip: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [
                                    ColorTheme.primary(for: themeManager.currentTheme),
                                    ColorTheme.dark(for: themeManager.currentTheme)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color(.systemGray6)
                        }
                    }
                )
                .cornerRadius(20)
                .shadow(
                    color: isSelected ? ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3) : .clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    HStack {
        FilterChip(title: "All", isSelected: true) {}
        FilterChip(title: "Today", isSelected: false) {}
        FilterChip(title: "Upcoming", isSelected: false) {}
    }
    .padding()
    .environmentObject(ThemeManager())
}

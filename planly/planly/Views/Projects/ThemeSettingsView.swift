//
//  ThemeSettingsView.swift
//  Planly
//
//  UI for selecting app color theme
//

import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background using current theme
                AnimatedThemeBackground()
                    .allowsHitTesting(false)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 50))
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
                            
                            Text("Choose Your Theme")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Personalize Planly with your favorite color palette")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Theme options
                        VStack(spacing: 12) {
                            ForEach(AppTheme.allCases) { theme in
                                ThemeOptionCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme == theme
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        themeManager.setTheme(theme)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Preview section
                        PreviewSection()
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Color Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
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

// MARK: - Theme Option Card
struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Theme icon with color preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [theme.lightColor, theme.primaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: theme.iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.darkColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .colorInvert()
                        .blendMode(.difference)
                }
                
                // Theme name
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Tap to apply")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.darkColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: isSelected ? theme.primaryColor.opacity(0.3) : .black.opacity(0.05),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview Section
struct PreviewSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                // Button preview
                HStack {
                    Spacer()
                    Button {
                        // Preview only
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Task")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [
                                    ColorTheme.primary(for: themeManager.currentTheme),
                                    ColorTheme.dark(for: themeManager.currentTheme)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    Spacer()
                }
                
                // Card preview
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.circle.fill")
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
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sample Task")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("This is how tasks will look")
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
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

// MARK: - Animated Background
struct AnimatedThemeBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(
                    ColorTheme.backgroundGradient(
                        for: themeManager.currentTheme,
                        from: .topTrailing
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? 100 : 150, y: -200)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    ColorTheme.backgroundGradient(
                        for: themeManager.currentTheme,
                        from: .bottomLeading
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? -100 : -150, y: 300)
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager())
}
// MARK: - Font Settings View

struct FontSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 50))
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
                        
                        Text("Font Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Customize how text appears in Planly")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Font Family Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font Family")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(AppFontFamily.allCases) { family in
                                FontFamilyCard(
                                    family: family,
                                    isSelected: fontManager.currentFontFamily == family
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        fontManager.setFontFamily(family)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Font Size Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font Size")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(AppFontSize.allCases) { size in
                                FontSizeCard(
                                    size: size,
                                    isSelected: fontManager.currentFontSize == size
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        fontManager.setFontSize(size)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Preview Section
                    FontPreviewSection()
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
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

// MARK: - Font Family Card
struct FontFamilyCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let family: AppFontFamily
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: family.iconName)
                        .font(.system(size: 22))
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
                }
                
                // Sample text in the font
                VStack(alignment: .leading, spacing: 4) {
                    Text(family.displayName)
                        .font(family.font(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("The quick brown fox")
                        .font(family.font(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
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
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: isSelected ? ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2) : .black.opacity(0.05),
                radius: isSelected ? 10 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Font Size Card
struct FontSizeCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    let size: AppFontSize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Size indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorTheme.primary(for: themeManager.currentTheme).opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text("Aa")
                        .font(fontManager.currentFontFamily.font(size: size.size(for: 20), weight: .semibold))
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
                }
                
                // Size name and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(size.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(Int(size.multiplier * 100))% of base size")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
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
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: isSelected ? ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2) : .black.opacity(0.05),
                radius: isSelected ? 10 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview Section
struct FontPreviewSection: View {
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                // Title preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(fontManager.font(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("This is how your task descriptions and other body text will appear throughout the app.")
                        .font(fontManager.font(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Button preview
                HStack {
                    Spacer()
                    Button {
                        // Preview only
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Task")
                                .font(fontManager.font(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [
                                    ColorTheme.primary(for: themeManager.currentTheme),
                                    ColorTheme.dark(for: themeManager.currentTheme)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: ColorTheme.primary(for: themeManager.currentTheme).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    Spacer()
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview("Font Settings") {
    FontSettingsView()
        .environmentObject(FontManager())
        .environmentObject(ThemeManager())
}


//
//  ThemeManager.swift
//  Planly
//
//  Manages the app's color theme
//

import SwiftUI
import Combine

/// Defines available color palettes for the app
enum AppTheme: String, CaseIterable, Identifiable {
    case pink = "Pink"
    case grey = "Grey & White"
    case lavender = "Lavender"
    case mint = "Mint"
    case peach = "Peach"
    case ocean = "Ocean Blue"
    
    var id: String { rawValue }
    
    /// Display name for the theme
    var displayName: String { rawValue }
    
    /// Primary accent color for the theme
    var primaryColor: Color {
        switch self {
        case .pink:
            return Color(red: 1.0, green: 0.85, blue: 0.9)
        case .grey:
            return Color(red: 0.6, green: 0.6, blue: 0.62)
        case .lavender:
            return Color(red: 0.9, green: 0.85, blue: 1.0)
        case .mint:
            return Color(red: 0.7, green: 0.95, blue: 0.9)
        case .peach:
            return Color(red: 1.0, green: 0.9, blue: 0.8)
        case .ocean:
            return Color(red: 0.7, green: 0.85, blue: 1.0)
        }
    }
    
    /// Darker shade of the primary color
    var darkColor: Color {
        switch self {
        case .pink:
            return Color(red: 1.0, green: 0.75, blue: 0.85)
        case .grey:
            return Color(red: 0.45, green: 0.45, blue: 0.47)
        case .lavender:
            return Color(red: 0.75, green: 0.7, blue: 0.95)
        case .mint:
            return Color(red: 0.5, green: 0.85, blue: 0.75)
        case .peach:
            return Color(red: 1.0, green: 0.75, blue: 0.6)
        case .ocean:
            return Color(red: 0.5, green: 0.7, blue: 0.95)
        }
    }
    
    /// Lighter shade of the primary color
    var lightColor: Color {
        switch self {
        case .pink:
            return Color(red: 1.0, green: 0.95, blue: 0.97)
        case .grey:
            return Color(red: 0.95, green: 0.95, blue: 0.96)
        case .lavender:
            return Color(red: 0.97, green: 0.95, blue: 1.0)
        case .mint:
            return Color(red: 0.9, green: 1.0, blue: 0.97)
        case .peach:
            return Color(red: 1.0, green: 0.97, blue: 0.93)
        case .ocean:
            return Color(red: 0.9, green: 0.95, blue: 1.0)
        }
    }
    
    /// Linear gradient from primary to dark
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, darkColor]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Radial gradient colors for backgrounds
    var backgroundGradientColors: [Color] {
        [primaryColor.opacity(0.15), .clear]
    }
    
    /// Icon name for theme preview
    var iconName: String {
        switch self {
        case .pink:
            return "heart.fill"
        case .grey:
            return "circle.fill"
        case .lavender:
            return "sparkles"
        case .mint:
            return "leaf.fill"
        case .peach:
            return "sun.max.fill"
        case .ocean:
            return "water.waves"
        }
    }
}

/// Manages the current app theme and persists user preference
@MainActor
class ThemeManager: ObservableObject {
    /// The currently selected theme
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    private let userDefaultsKey = "selectedAppTheme"
    
    init() {
        // Load saved theme or default to pink
        if let savedTheme = UserDefaults.standard.string(forKey: userDefaultsKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .pink
        }
    }
    
    /// Save the current theme to UserDefaults
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: userDefaultsKey)
    }
    
    /// Update the theme (triggers UI refresh)
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}



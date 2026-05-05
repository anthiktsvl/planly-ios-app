//
//  FontManager.swift
//  Planly
//
//  Manages the app's font family and size preferences
//

import SwiftUI
import Combine

/// Available font families for the app
enum AppFontFamily: String, CaseIterable, Identifiable {
    case system = "System"
    case rounded = "Rounded"
    case serif = "Serif"
    case monospaced = "Monospaced"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    /// Apply the font family to text
    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }
    
    /// Icon representation for preview
    var iconName: String {
        switch self {
        case .system:
            return "textformat"
        case .rounded:
            return "textformat.alt"
        case .serif:
            return "text.book.closed"
        case .monospaced:
            return "terminal"
        }
    }
}

/// Available font size presets
enum AppFontSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    /// Multiplier for base font sizes
    var multiplier: CGFloat {
        switch self {
        case .small:
            return 0.9
        case .medium:
            return 1.0
        case .large:
            return 1.15
        case .extraLarge:
            return 1.3
        }
    }
    
    /// Get scaled font size
    func size(for baseSize: CGFloat) -> CGFloat {
        return baseSize * multiplier
    }
}

/// Manages font preferences and persists user selection
@MainActor
class FontManager: ObservableObject {
    /// The currently selected font family
    @Published var currentFontFamily: AppFontFamily {
        didSet {
            saveFontFamily()
        }
    }
    
    /// The currently selected font size
    @Published var currentFontSize: AppFontSize {
        didSet {
            saveFontSize()
        }
    }
    
    private let fontFamilyKey = "selectedFontFamily"
    private let fontSizeKey = "selectedFontSize"
    
    init() {
        // Load saved font family or default to system
        if let savedFamily = UserDefaults.standard.string(forKey: fontFamilyKey),
           let family = AppFontFamily(rawValue: savedFamily) {
            self.currentFontFamily = family
        } else {
            self.currentFontFamily = .system
        }
        
        // Load saved font size or default to medium
        if let savedSize = UserDefaults.standard.string(forKey: fontSizeKey),
           let size = AppFontSize(rawValue: savedSize) {
            self.currentFontSize = size
        } else {
            self.currentFontSize = .medium
        }
    }
    
    /// Save the current font family to UserDefaults
    private func saveFontFamily() {
        UserDefaults.standard.set(currentFontFamily.rawValue, forKey: fontFamilyKey)
    }
    
    /// Save the current font size to UserDefaults
    private func saveFontSize() {
        UserDefaults.standard.set(currentFontSize.rawValue, forKey: fontSizeKey)
    }
    
    /// Update the font family
    func setFontFamily(_ family: AppFontFamily) {
        currentFontFamily = family
    }
    
    /// Update the font size
    func setFontSize(_ size: AppFontSize) {
        currentFontSize = size
    }
    
    /// Get a font with the current family and a specific size
    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaledSize = currentFontSize.size(for: size)
        return currentFontFamily.font(size: scaledSize, weight: weight)
    }
    
    /// Get a font based on TextStyle (like .body, .headline, etc.)
    func font(for textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        let baseSize = baseSizeForTextStyle(textStyle)
        let scaledSize = currentFontSize.size(for: baseSize)
        return currentFontFamily.font(size: scaledSize, weight: weight)
    }
    
    /// Map TextStyle to base font sizes
    private func baseSizeForTextStyle(_ textStyle: Font.TextStyle) -> CGFloat {
        switch textStyle {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}
// MARK: - SwiftUI Extensions for Easy Font Application

/// Custom view modifier to apply fonts from FontManager
struct AdaptiveFontModifier: ViewModifier {
    @EnvironmentObject var fontManager: FontManager
    let textStyle: Font.TextStyle
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(fontManager.font(for: textStyle, weight: weight))
    }
}

extension View {
    /// Apply a font from the FontManager based on text style
    func adaptiveFont(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        self.modifier(AdaptiveFontModifier(textStyle: textStyle, weight: weight))
    }
}


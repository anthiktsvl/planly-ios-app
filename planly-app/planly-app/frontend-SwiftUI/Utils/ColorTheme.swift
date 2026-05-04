//
//  ColorTheme.swift
//  Planly
//
//  Color theme definitions for the app
//

import SwiftUI

struct ColorTheme {
    // Baby Pink shades
    static let babyPink = Color(red: 1.0, green: 0.85, blue: 0.9)
    static let babyPinkDark = Color(red: 1.0, green: 0.75, blue: 0.85)
    static let babyPinkLight = Color(red: 1.0, green: 0.95, blue: 0.97)
    
    // White shades
    static let pureWhite = Color.white
    static let offWhite = Color(red: 0.98, green: 0.98, blue: 0.99)
    
    // Text colors
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.25)
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.55)
    static let textOnPink = Color.white
    
    // Gradient
    static let pinkGradient = LinearGradient(
        gradient: Gradient(colors: [babyPinkLight, babyPink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [babyPink, babyPinkDark]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

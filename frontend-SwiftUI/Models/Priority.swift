//
//  Priority.swift
//  Planly
//

import SwiftUI

extension TaskItem {
    enum Priority: String, Codable, CaseIterable, Hashable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return ColorTheme.babyPinkLight
            case .medium: return ColorTheme.babyPink
            case .high: return ColorTheme.babyPinkDark
            }
        }
    }
}

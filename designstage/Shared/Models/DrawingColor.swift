//
//  DrawingColor.swift
//  Design Stage
//
//  Preset drawing colors.
//

import Cocoa

enum DrawingColor: Int, CaseIterable {
    case yellow = 0
    case red = 1
    case blue = 2
    case green = 3
    case white = 4
    
    var displayName: String {
        switch self {
        case .yellow: return "Yellow"
        case .red: return "Red"
        case .blue: return "Blue"
        case .green: return "Green"
        case .white: return "White"
        }
    }
    
    var nsColor: NSColor {
        switch self {
        case .yellow: return NSColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        case .red: return NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        case .blue: return NSColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        case .green: return NSColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
        case .white: return NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}


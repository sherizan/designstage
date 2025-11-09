//
//  BrushWidth.swift
//  Design Stage
//
//  Brush stroke width presets.
//

import Foundation
import CoreGraphics

enum BrushWidth: Int, CaseIterable {
    case light = 0
    case regular = 1
    case heavy = 2
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .regular: return "Regular"
        case .heavy: return "Heavy"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .light: return 2.0
        case .regular: return 4.0
        case .heavy: return 6.0
        }
    }
}


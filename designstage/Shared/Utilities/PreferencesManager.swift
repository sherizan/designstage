//
//  PreferencesManager.swift
//  Design Stage
//
//  Manages user preferences persistence using UserDefaults.
//

import Foundation

class PreferencesManager {
    static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let drawingColor = "drawingColor"
        static let fadeMode = "fadeMode"
        static let brushWidth = "brushWidth"
    }
    
    private init() {}
    
    // MARK: - Drawing Color
    
    var drawingColor: DrawingColor {
        get {
            let rawValue = defaults.integer(forKey: Keys.drawingColor)
            return DrawingColor(rawValue: rawValue) ?? .green
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.drawingColor)
        }
    }
    
    // MARK: - Fade Mode
    
    var fadeMode: FadeMode {
        get {
            let rawValue = defaults.integer(forKey: Keys.fadeMode)
            return FadeMode(rawValue: rawValue) ?? .fiveSeconds
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.fadeMode)
        }
    }
    
    // MARK: - Brush Width
    
    var brushWidth: BrushWidth {
        get {
            let rawValue = defaults.integer(forKey: Keys.brushWidth)
            return BrushWidth(rawValue: rawValue) ?? .regular
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.brushWidth)
        }
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        drawingColor = .green
        fadeMode = .fiveSeconds
        brushWidth = .regular
    }
}


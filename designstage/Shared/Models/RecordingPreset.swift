//
//  RecordingPreset.swift
//  Design Stage
//
//  Defines preset recording dimensions for quick selection.
//

import Foundation
import CoreGraphics

struct RecordingPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat
    
    var dimensions: CGSize {
        CGSize(width: width, height: height)
    }
    
    var aspectRatio: CGFloat {
        width / height
    }
    
    // Predefined presets
    static let square = RecordingPreset(id: "square", name: "Square", width: 1080, height: 1080)
    static let landscape = RecordingPreset(id: "landscape", name: "Landscape", width: 1280, height: 720)
    static let portrait = RecordingPreset(id: "portrait", name: "Portrait", width: 393, height: 852)
    
    static let allPresets: [RecordingPreset] = [
        .square,
        .landscape,
        .portrait
    ]
    
    func displayDimensions() -> String {
        return "\(Int(width)) × \(Int(height))"
    }
}


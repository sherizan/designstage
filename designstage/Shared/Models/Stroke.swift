//
//  Stroke.swift
//  Design Stage
//
//  Represents a single drawing stroke.
//

import Foundation
import CoreGraphics

struct Stroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    let color: DrawingColor
    let width: CGFloat
    let birthTime: CFTimeInterval
}


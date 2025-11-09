//
//  FadeEngine.swift
//  Design Stage
//
//  Actor-based engine for managing stroke fade animations.
//

import Foundation
import QuartzCore

@MainActor
final class FadeEngine {
    private var registeredStrokes: [UUID: Stroke] = [:]
    private var fadeMode: FadeMode = .off
    
    func registerStroke(_ stroke: Stroke) {
        registeredStrokes[stroke.id] = stroke
    }
    
    func setFadeMode(_ mode: FadeMode) {
        fadeMode = mode
    }
    
    func clearAllStrokes() {
        registeredStrokes.removeAll()
    }
    
    func alphaForStroke(_ stroke: Stroke, at currentTime: CFTimeInterval) -> CGFloat {
        let mode = fadeMode
        
        guard mode != .off else { return 1.0 }
        
        let elapsed = currentTime - stroke.birthTime
        let duration = mode.duration
        
        if elapsed >= duration {
            return 0.0
        }
        
        // Ease-out quad fade
        let progress = elapsed / duration
        let alpha = 1.0 - easeOutQuad(progress)
        
        return CGFloat(max(0.0, min(1.0, alpha)))
    }
    
    private nonisolated func easeOutQuad(_ t: Double) -> Double {
        return t * (2.0 - t)
    }
}


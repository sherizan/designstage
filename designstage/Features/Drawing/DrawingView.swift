//
//  DrawingView.swift
//  Design Stage
//
//  Custom NSView for capturing and rendering drawing strokes.
//

import Cocoa
import QuartzCore

class DrawingView: NSView {
    private var strokes: [Stroke] = []
    private var currentStroke: Stroke?
    private let fadeEngine: FadeEngine?
    
    var currentColor: DrawingColor = .yellow
    var lineWidth: CGFloat = 3.0
    
    init(fadeEngine: FadeEngine?) {
        self.fadeEngine = fadeEngine
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Mouse Events
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        
        // Ignore clicks outside visible bounds (e.g., menu bar area)
        guard bounds.contains(location) else { return }
        
        currentStroke = Stroke(
            points: [location],
            color: currentColor,
            width: lineWidth,
            birthTime: CACurrentMediaTime()
        )
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        
        // Only add points within visible bounds
        guard bounds.contains(location) else { return }
        
        currentStroke?.points.append(location)
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        if let stroke = currentStroke {
            strokes.append(stroke)
            fadeEngine?.registerStroke(stroke)
            currentStroke = nil
        }
        needsDisplay = true
    }
    
    // MARK: - Drawing
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        let currentTime = CACurrentMediaTime()
        
        // Draw completed strokes
        for stroke in strokes {
            let alpha = fadeEngine?.alphaForStroke(stroke, at: currentTime) ?? 1.0
            
            if alpha > 0.01 {
                drawStroke(stroke, in: context, alpha: alpha)
            }
        }
        
        // Draw current stroke being drawn
        if let current = currentStroke {
            drawStroke(current, in: context, alpha: 1.0)
        }
        
        // Clean up fully faded strokes
        strokes.removeAll { stroke in
            let alpha = fadeEngine?.alphaForStroke(stroke, at: currentTime) ?? 1.0
            return alpha <= 0.01
        }
    }
    
    private func drawStroke(_ stroke: Stroke, in context: CGContext, alpha: CGFloat) {
        guard stroke.points.count > 1 else { return }
        
        context.saveGState()
        
        let color = stroke.color.nsColor.withAlphaComponent(alpha)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(stroke.width)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        context.beginPath()
        context.move(to: stroke.points[0])
        
        for point in stroke.points.dropFirst() {
            context.addLine(to: point)
        }
        
        context.strokePath()
        context.restoreGState()
    }
    
    func clearAllStrokes() {
        strokes.removeAll()
        currentStroke = nil
        fadeEngine?.clearAllStrokes()
        needsDisplay = true
    }
    
    func cancelCurrentStroke() {
        currentStroke = nil
        needsDisplay = true
    }
}


//
//  SafeRegionSelectorWindow.swift
//  Design Stage
//
//  Crash-safe region selection window for screen recording.
//

import Cocoa

class SafeRegionSelectorWindow: NSWindow {
    private var onRegionSelected: ((CGRect?) -> Void)?
    private var startPoint: NSPoint?
    private var currentRect: NSRect = .zero
    private var overlayView: RegionOverlayView?
    
    init(onRegionSelected: @escaping (CGRect?) -> Void) {
        // Store callback safely
        self.onRegionSelected = onRegionSelected
        
        // Use main screen frame
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupOverlayView()
    }
    
    private func setupWindow() {
        level = .screenSaver
        backgroundColor = NSColor.clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        
        // Show on main screen
        if let screen = NSScreen.main {
            setFrame(screen.frame, display: true)
        }
    }
    
    private func setupOverlayView() {
        overlayView = RegionOverlayView()
        overlayView?.wantsLayer = true
        overlayView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
        
        if let overlayView = overlayView {
            contentView = overlayView
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentRect = NSRect(origin: startPoint!, size: .zero)
        overlayView?.selectionRect = currentRect
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        
        let currentPoint = event.locationInWindow
        let rect = NSRect(
            x: min(start.x, currentPoint.x),
            y: min(start.y, currentPoint.y),
            width: abs(currentPoint.x - start.x),
            height: abs(start.y - currentPoint.y)
        )
        
        currentRect = rect
        overlayView?.selectionRect = rect
        overlayView?.needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        // Convert to screen coordinates
        let screenRect = convertRectToScreenCoordinates(currentRect)
        
        // Close window first, then call callback
        close()
        
        // Call callback after a delay to ensure window is fully closed
        let callback = onRegionSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("📹 SafeRegionSelectorWindow calling callback with region: \(screenRect)")
            callback?(screenRect)
        }
        onRegionSelected = nil // Clear callback
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.onRegionSelected?(nil)
                self?.onRegionSelected = nil // Clear callback
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
    private func convertRectToScreenCoordinates(_ rect: NSRect) -> CGRect {
        // Convert from window coordinates to screen coordinates
        guard let screen = NSScreen.main else { 
            return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
        }
        
        let screenFrame = screen.frame
        let convertedY = screenFrame.height - rect.origin.y - rect.height
        
        return CGRect(
            x: rect.origin.x,
            y: convertedY,
            width: rect.width,
            height: rect.height
        )
    }
}

class RegionOverlayView: NSView {
    var selectionRect: NSRect = .zero
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw semi-transparent overlay
        NSColor.black.withAlphaComponent(0.3).setFill()
        bounds.fill()
        
        // Cut out selection area
        if selectionRect.width > 0 && selectionRect.height > 0 {
            NSColor.clear.setFill()
            selectionRect.fill(using: .sourceOver)
            
            // Draw selection border
            NSColor.white.setStroke()
            let borderPath = NSBezierPath(rect: selectionRect)
            borderPath.lineWidth = 2.0
            borderPath.stroke()
        }
    }
}

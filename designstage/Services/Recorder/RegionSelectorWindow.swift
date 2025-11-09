//
//  RegionSelectorWindow.swift
//  Design Stage
//
//  Simple region selection window for screen recording.
//

import Cocoa

class RegionSelectorWindow: NSWindow {
    private let onRegionSelected: (CGRect?) -> Void
    
    init(onRegionSelected: @escaping (CGRect?) -> Void) {
        self.onRegionSelected = onRegionSelected
        
        // Use main screen only to avoid complexity
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
    }
    
    private func setupWindow() {
        level = .screenSaver
        backgroundColor = NSColor.black.withAlphaComponent(0.3)
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        
        // Simplified - just show on main screen
        setFrame(frame, display: true)
    }
    
    override func mouseDown(with event: NSEvent) {
        // Simple click anywhere to select a test region
        let testRegion = CGRect(x: 100, y: 100, width: 800, height: 600)
        
        // Close first, then call callback to avoid cleanup timing issues
        close()
        onRegionSelected(testRegion)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            close()
            onRegionSelected(nil)
        } else {
            super.keyDown(with: event)
        }
    }
}

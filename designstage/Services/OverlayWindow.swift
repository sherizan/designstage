//
//  OverlayWindow.swift
//  Design Stage
//
//  Transparent NSPanel that covers all screens for drawing overlay.
//

import Cocoa

class OverlayWindow: NSPanel {
    init() {
        // Create a window that spans all screens
        let mainScreen = NSScreen.main ?? NSScreen.screens[0]
        
        super.init(
            contentRect: mainScreen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // Configure as transparent overlay
        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        
        // Accept mouse and key events
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        
        // Span all screens
        updateFrame()
        
        // Update frame when screen configuration changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFrame),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func updateFrame() {
        // Calculate union of all screen frames
        var totalFrame = NSRect.zero
        for screen in NSScreen.screens {
            totalFrame = totalFrame.union(screen.frame)
        }
        self.setFrame(totalFrame, display: true)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}


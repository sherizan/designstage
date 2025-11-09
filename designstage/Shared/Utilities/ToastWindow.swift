//
//  ToastWindow.swift
//  Design Stage
//
//  Displays temporary toast notifications on screen.
//

import Cocoa
import SwiftUI

class ToastWindow: NSPanel {
    init(message: String, isEnabled: Bool = true) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 80),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.level = .statusBar
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        
        // Create SwiftUI content
        let hostingView = NSHostingView(rootView: ToastView(message: message, isEnabled: isEnabled))
        self.contentView = hostingView
        
        // Center on main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowOrigin = NSPoint(
                x: screenFrame.midX - self.frame.width / 2,
                y: screenFrame.maxY - 100 // 100pt from top
            )
            self.setFrameOrigin(windowOrigin)
        }
    }
    
    func show(duration: TimeInterval = 5.0) {
        self.alphaValue = 0
        self.orderFrontRegardless()
        
        // Fade in
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            self.animator().alphaValue = 1.0
        })
        
        // Auto-dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.dismiss()
        }
    }
    
    private func dismiss() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            self.animator().alphaValue = 0
        }, completionHandler: {
            self.close()
        })
    }
}

struct ToastView: View {
    let message: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isEnabled ? "pencil.tip.crop.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isEnabled ? "Drawing Mode Active" : "Drawing Mode Off")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEnabled ? Color.black.opacity(0.85) : Color.red.opacity(0.85))
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}


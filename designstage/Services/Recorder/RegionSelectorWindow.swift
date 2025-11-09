//
//  RegionSelectorWindow.swift
//  Design Stage
//
//  Interactive region selector for screen recording.
//

import Cocoa

class RegionSelectorWindow: NSWindow {
    private var selectionView: RegionSelectionView
    private let completion: (CGRect?) -> Void
    
    init(completion: @escaping (CGRect?) -> Void) {
        self.completion = completion
        self.selectionView = RegionSelectionView()
        
        // Cover all screens
        var totalFrame = NSRect.zero
        for screen in NSScreen.screens {
            totalFrame = totalFrame.union(screen.frame)
        }
        
        super.init(
            contentRect: totalFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.level = .screenSaver
        self.backgroundColor = NSColor.black.withAlphaComponent(0.3)
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.contentView = selectionView
        
        selectionView.onComplete = { [weak self] region in
            self?.completion(region)
        }
        
        selectionView.onCancel = { [weak self] in
            self?.completion(nil)
        }
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}

class RegionSelectionView: NSView {
    var onComplete: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?
    
    private var startPoint: CGPoint?
    private var currentRect: CGRect?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)
        
        let minX = min(start.x, current.x)
        let minY = min(start.y, current.y)
        let width = abs(current.x - start.x)
        let height = abs(current.y - start.y)
        
        currentRect = CGRect(x: minX, y: minY, width: width, height: height)
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        if let rect = currentRect {
            onComplete?(rect)
        } else {
            onCancel?()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            onCancel?()
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext,
              let rect = currentRect else { return }
        
        // Draw selection rectangle
        context.setStrokeColor(NSColor.white.cgColor)
        context.setLineWidth(2.0)
        context.stroke(rect)
        
        // Draw dimension label
        let dimensions = String(format: "%.0f × %.0f", rect.width, rect.height)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        
        let textSize = dimensions.size(withAttributes: attributes)
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.maxY + 10,
            width: textSize.width,
            height: textSize.height
        )
        
        dimensions.draw(in: textRect, withAttributes: attributes)
    }
}


//
//  OverlayService.swift
//  Design Stage
//
//  Manages the transparent overlay window for drawing.
//

import Cocoa

@MainActor
class OverlayService: ObservableObject {
    private var overlayWindow: OverlayWindow?
    private var drawingViewController: DrawingViewController?
    private var fadeEngine: FadeEngine?
    
    @Published var isDrawingEnabled = false
    @Published var currentColor: DrawingColor = .green
    @Published var currentFadeMode: FadeMode = .fiveSeconds
    @Published var currentBrushWidth: BrushWidth = .regular
    
    init() {
        self.fadeEngine = FadeEngine()
        
        // Load saved preferences
        let prefs = PreferencesManager.shared
        self.currentColor = prefs.drawingColor
        self.currentFadeMode = prefs.fadeMode
        self.currentBrushWidth = prefs.brushWidth
        self.fadeEngine?.setFadeMode(prefs.fadeMode)
    }
    
    func toggleDrawing() {
        if isDrawingEnabled {
            hideOverlay()
            showToastMessage(isEnabled: false)
        } else {
            showOverlay()
            showToastMessage(isEnabled: true)
        }
        isDrawingEnabled.toggle()
        
        // Notify menu to update
        NotificationCenter.default.post(
            name: NSNotification.Name("DrawingStateChanged"),
            object: nil,
            userInfo: ["isEnabled": isDrawingEnabled]
        )
    }
    
    private func showToastMessage(isEnabled: Bool) {
        let message = isEnabled ? "Press ⌘⇧D to turn off" : "Drawing mode disabled"
        let toast = ToastWindow(message: message, isEnabled: isEnabled)
        toast.show(duration: 3.0)
    }
    
    func clearDrawing() {
        drawingViewController?.clearAllStrokes()
    }
    
    func setColor(_ color: DrawingColor) {
        currentColor = color
        drawingViewController?.setCurrentColor(color)
        PreferencesManager.shared.drawingColor = color
    }
    
    func setFadeMode(_ mode: FadeMode) {
        currentFadeMode = mode
        fadeEngine?.setFadeMode(mode)
        PreferencesManager.shared.fadeMode = mode
    }
    
    func setBrushWidth(_ width: BrushWidth) {
        currentBrushWidth = width
        drawingViewController?.setBrushWidth(width.width)
        PreferencesManager.shared.brushWidth = width
    }
    
    func cycleFadeMode() {
        let modes = FadeMode.allCases
        if let currentIndex = modes.firstIndex(of: currentFadeMode) {
            let nextIndex = (currentIndex + 1) % modes.count
            setFadeMode(modes[nextIndex])
        }
    }
    
    private func showOverlay() {
        if overlayWindow == nil {
            overlayWindow = OverlayWindow()
            drawingViewController = DrawingViewController(fadeEngine: fadeEngine)
            drawingViewController?.currentColor = currentColor
            drawingViewController?.setBrushWidth(currentBrushWidth.width)
            
            if let contentView = overlayWindow?.contentView {
                let view = drawingViewController!.view
                view.frame = contentView.bounds
                view.autoresizingMask = [.width, .height]
                contentView.addSubview(view)
            }
        }
        
        overlayWindow?.orderFrontRegardless()
        overlayWindow?.makeKey()
    }
    
    private func hideOverlay() {
        // Cancel any in-progress stroke
        drawingViewController?.cancelCurrentStroke()
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        drawingViewController = nil
    }
}


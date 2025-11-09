//
//  StatusItemController.swift
//  Design Stage
//
//  Manages the menu bar item and its menu.
//

import Cocoa

class StatusItemController {
    private let statusItem: NSStatusItem?
    private weak var overlayService: OverlayService?
    private weak var recordingService: RecordingService?
    private var menu: NSMenu
    private var stateObserver: Any?
    
    // State tracking - synced from OverlayService
    private var isDrawingEnabled = false
    private var currentFadeMode: FadeMode = .fiveSeconds
    private var currentColor: DrawingColor = .green
    private var currentBrushWidth: BrushWidth = .regular
    
    init(statusItem: NSStatusItem?, overlayService: OverlayService?, recordingService: RecordingService?) {
        self.statusItem = statusItem
        self.overlayService = overlayService
        self.recordingService = recordingService
        self.menu = NSMenu()
        
        // Load saved preferences
        let prefs = PreferencesManager.shared
        self.currentColor = prefs.drawingColor
        self.currentFadeMode = prefs.fadeMode
        self.currentBrushWidth = prefs.brushWidth
        
        buildMenu()
        statusItem?.menu = menu
        
        // Observe drawing state changes
        setupStateObserver()
    }
    
    deinit {
        if let observer = stateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupStateObserver() {
        guard overlayService != nil else { return }
        
        stateObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DrawingStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let isEnabled = notification.userInfo?["isEnabled"] as? Bool {
                self?.isDrawingEnabled = isEnabled
                self?.buildMenu()
            }
        }
    }
    
    private func buildMenu() {
        menu.removeAllItems()
        
        // MARK: - Drawing Section
        
        // Toggle Draw
        let drawItem = NSMenuItem(
            title: isDrawingEnabled ? "Disable Draw (⌘⇧D)" : "Enable Draw (⌘⇧D)",
            action: #selector(toggleDraw),
            keyEquivalent: ""
        )
        drawItem.target = self
        menu.addItem(drawItem)
        
        // Clear Screen
        let clearItem = NSMenuItem(
            title: "Clear Screen (⌘⇧C)",
            action: #selector(clearScreen),
            keyEquivalent: ""
        )
        clearItem.target = self
        clearItem.isEnabled = isDrawingEnabled
        menu.addItem(clearItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Fade Ink submenu
        let fadeMenu = NSMenu()
        for mode in FadeMode.allCases {
            let fadeItem = NSMenuItem(
                title: mode.displayName,
                action: #selector(selectFadeMode(_:)),
                keyEquivalent: ""
            )
            fadeItem.target = self
            fadeItem.tag = mode.rawValue
            fadeItem.state = (mode == currentFadeMode) ? .on : .off
            fadeMenu.addItem(fadeItem)
        }
        
        let fadeSubmenu = NSMenuItem(title: "Fade Ink", action: nil, keyEquivalent: "")
        fadeSubmenu.submenu = fadeMenu
        menu.addItem(fadeSubmenu)
        
        // Color Presets submenu
        let colorMenu = NSMenu()
        for color in DrawingColor.allCases {
            let colorItem = NSMenuItem(
                title: color.displayName,
                action: #selector(selectColor(_:)),
                keyEquivalent: ""
            )
            colorItem.target = self
            colorItem.tag = color.rawValue
            colorItem.state = (color == currentColor) ? .on : .off
            colorMenu.addItem(colorItem)
        }
        
        let colorSubmenu = NSMenuItem(title: "Color Presets", action: nil, keyEquivalent: "")
        colorSubmenu.submenu = colorMenu
        menu.addItem(colorSubmenu)
        
        // Brush Width submenu
        let widthMenu = NSMenu()
        for width in BrushWidth.allCases {
            let widthItem = NSMenuItem(
                title: width.displayName,
                action: #selector(selectBrushWidth(_:)),
                keyEquivalent: ""
            )
            widthItem.target = self
            widthItem.tag = width.rawValue
            widthItem.state = (width == currentBrushWidth) ? .on : .off
            widthMenu.addItem(widthItem)
        }
        
        let widthSubmenu = NSMenuItem(title: "Brush Width", action: nil, keyEquivalent: "")
        widthSubmenu.submenu = widthMenu
        menu.addItem(widthSubmenu)
        
        menu.addItem(NSMenuItem.separator())
        
        // MARK: - Recording & Export Section
        
        // Record Region
        let recordItem = NSMenuItem(
            title: "Record Region (⌘⇧R)",
            action: #selector(startRecording),
            keyEquivalent: ""
        )
        recordItem.target = self
        menu.addItem(recordItem)
        
        // Export Snapshot
        let exportItem = NSMenuItem(
            title: "Export Snapshot (⌘⇧S)",
            action: #selector(exportSnapshot),
            keyEquivalent: ""
        )
        exportItem.target = self
        menu.addItem(exportItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // MARK: - Frame Presets Section
        
        // Frame Presets submenu
        let frameMenu = NSMenu()
        let presets = [
            "iPhone 15 Pro (1179×2556)",
            "iPad Pro 11\" (1668×2388)",
            "1080p (1920×1080)",
            "1440p (2560×1440)",
            "4K (3840×2160)",
            "Custom Size..."
        ]
        
        for preset in presets {
            let frameItem = NSMenuItem(
                title: preset,
                action: #selector(openFramePreset(_:)),
                keyEquivalent: ""
            )
            frameItem.target = self
            frameMenu.addItem(frameItem)
        }
        
        let frameSubmenu = NSMenuItem(title: "Frame Preset", action: nil, keyEquivalent: "")
        frameSubmenu.submenu = frameMenu
        menu.addItem(frameSubmenu)
        
        menu.addItem(NSMenuItem.separator())
        
        // MARK: - Settings
        
        // Launch at Login
        let launchItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = PreferencesManager.shared.launchAtLogin ? .on : .off
        menu.addItem(launchItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // MARK: - Quit
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Design Stage",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    // MARK: - Actions
    
    @objc private func toggleDraw() {
        Task { @MainActor in
            overlayService?.toggleDrawing()
        }
    }
    
    @objc private func clearScreen() {
        Task { @MainActor in
            overlayService?.clearDrawing()
        }
    }
    
    @objc private func selectFadeMode(_ sender: NSMenuItem) {
        if let mode = FadeMode(rawValue: sender.tag) {
            Task { @MainActor in
                currentFadeMode = mode
                overlayService?.setFadeMode(mode)
                buildMenu()
            }
        }
    }
    
    @objc private func selectColor(_ sender: NSMenuItem) {
        if let color = DrawingColor(rawValue: sender.tag) {
            Task { @MainActor in
                currentColor = color
                overlayService?.setColor(color)
                buildMenu()
            }
        }
    }
    
    @objc private func selectBrushWidth(_ sender: NSMenuItem) {
        if let width = BrushWidth(rawValue: sender.tag) {
            Task { @MainActor in
                currentBrushWidth = width
                overlayService?.setBrushWidth(width)
                buildMenu()
            }
        }
    }
    
    @objc private func startRecording() {
        Task { @MainActor in
            guard let service = recordingService else { return }
            
            switch service.state {
            case .idle:
                print("🟡 Menu: Starting recording")
                service.startRegionSelection()
            case .selectingRegion:
                print("🟡 Menu: Already selecting region")
                break
            case .recording:
                print("🟡 Menu: Stopping recording")
                service.stopRecording()
            }
        }
    }
    
    @objc private func openFramePreset(_ sender: NSMenuItem) {
        // TODO: Implement frame presets
        print("Open frame preset: \(sender.title)")
    }
    
    @objc private func exportSnapshot() {
        // TODO: Implement snapshot export
        print("Export snapshot")
    }
    
    @objc private func toggleLaunchAtLogin() {
        PreferencesManager.shared.launchAtLogin.toggle()
        buildMenu()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}


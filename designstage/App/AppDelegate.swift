//
//  AppDelegate.swift
//  Design Stage
//
//  Manages app lifecycle, menu bar status item, and permissions coordination.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var statusItemController: StatusItemController?
    private var overlayService: OverlayService?
    private var hotkeyManager: HotkeyManager?
    private var recordingService: RecordingService?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock - menu bar app only
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize services
        overlayService = OverlayService()
        hotkeyManager = HotkeyManager()
        recordingService = RecordingService()
        
        // Set up menu bar
        setupMenuBar()
        
        // Register global hotkeys
        registerHotkeys()
        
        // Request permissions on first launch
        checkPermissions()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregisterAll()
    }
    
    private func setupMenuBar() {
        // Remove existing status item if any
        if let existingItem = statusItem {
            NSStatusBar.system.removeStatusItem(existingItem)
            statusItem = nil
            statusItemController = nil
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "pencil.tip.crop.circle", accessibilityDescription: "Design Stage")
        }
        
        statusItemController = StatusItemController(
            statusItem: statusItem,
            overlayService: overlayService,
            recordingService: recordingService
        )
    }
    
    private func registerHotkeys() {
        guard let hotkeyManager = hotkeyManager,
              overlayService != nil else { return }
        
        // ⌘⇧D - Toggle Draw
        hotkeyManager.register(keyCode: 2, modifiers: [.command, .shift]) { [weak self] in
            Task { @MainActor [weak self] in
                self?.overlayService?.toggleDrawing()
            }
        }
        
        // ⌘⇧C - Clear Screen
        hotkeyManager.register(keyCode: 8, modifiers: [.command, .shift]) { [weak self] in
            Task { @MainActor [weak self] in
                self?.overlayService?.clearDrawing()
            }
        }
        
        // ⌘⇧F - Toggle Fade
        hotkeyManager.register(keyCode: 3, modifiers: [.command, .shift]) { [weak self] in
            Task { @MainActor [weak self] in
                self?.overlayService?.cycleFadeMode()
            }
        }
        
        // ⌘⇧R - Toggle Recording (Start/Stop)
        hotkeyManager.register(keyCode: 15, modifiers: [.command, .shift]) { [weak self] in
            Task { @MainActor [weak self] in
                self?.toggleRecording()
            }
        }
        
        // ⌘⇧S - Export Snapshot
        hotkeyManager.register(keyCode: 1, modifiers: [.command, .shift]) {
            // TODO: Implement snapshot export
            print("Export snapshot triggered")
        }
    }
    
    private func checkPermissions() {
        // Screen Recording permission required for overlay and recording
        Task {
            await PermissionsManager.shared.requestScreenRecordingPermission()
        }
    }
    
    @MainActor
    private func toggleRecording() {
        guard let service = recordingService else { return }
        
        switch service.state {
        case .idle:
            service.startRegionSelection()
        case .selectingRegion:
            // Already selecting region, do nothing (or could cancel)
            break
        case .recording:
            service.stopRecording()
        }
    }
}


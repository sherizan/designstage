//
//  PermissionsManager.swift
//  Design Stage
//
//  Manages system permissions for screen recording and accessibility.
//

import Cocoa
import ScreenCaptureKit

@MainActor
class PermissionsManager {
    static let shared = PermissionsManager()
    
    private init() {}
    
    func requestScreenRecordingPermission() async {
        // Check if we have screen recording permission
        if #available(macOS 12.3, *) {
            do {
                // Requesting available content will prompt for permission if needed
                _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            } catch {
                // If permission denied, show alert
                showPermissionAlert()
            }
        } else {
            // Fallback for older macOS versions
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "Design Stage needs Screen Recording permission to display the drawing overlay and capture recordings.\n\nPlease enable it in System Preferences > Privacy & Security > Screen Recording."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            openSystemPreferences()
        }
    }
    
    private func openSystemPreferences() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenRecording")!)
        }
    }
}


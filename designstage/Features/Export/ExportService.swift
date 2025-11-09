//
//  ExportService.swift
//  Design Stage
//
//  Handles snapshot export functionality.
//

import Cocoa
import CoreGraphics

@MainActor
class ExportService {
    func exportSnapshot(includeDrawings: Bool = true) {
        // Capture screen
        guard let image = captureScreen() else {
            showError("Failed to capture screen")
            return
        }
        
        // Show save panel
        let savePanel = NSSavePanel()
        savePanel.title = "Export Snapshot"
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "DesignStage-\(Date().timeIntervalSince1970).png"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                self.saveImage(image, to: url)
            }
        }
    }
    
    private func captureScreen() -> NSImage? {
        guard let screen = NSScreen.main else { return nil }
        
        let rect = screen.frame
        let screenID = CGMainDisplayID()
        
        guard let cgImage = CGDisplayCreateImage(screenID, rect: CGRect(
            x: 0,
            y: 0,
            width: rect.width,
            height: rect.height
        )) else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: rect.size)
    }
    
    private func saveImage(_ image: NSImage, to url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            showError("Failed to convert image")
            return
        }
        
        do {
            try pngData.write(to: url)
            showSuccess(url: url)
        } catch {
            showError("Failed to save: \(error.localizedDescription)")
        }
    }
    
    private func showSuccess(url: URL) {
        let alert = NSAlert()
        alert.messageText = "Snapshot Saved"
        alert.informativeText = "Your snapshot has been saved to:\n\(url.path)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open in Finder")
        alert.addButton(withTitle: "OK")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
        }
    }
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Failed"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
    }
}


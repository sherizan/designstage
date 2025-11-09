//
//  RecordingService.swift
//  Design Stage
//
//  Manages screen recording with region selection.
//

import Cocoa
import AVFoundation
import ScreenCaptureKit

@MainActor
class RecordingService: ObservableObject {
    enum RecordingState: Equatable {
        case idle
        case selectingRegion
        case recording(startTime: Date)
    }
    
    @Published var state: RecordingState = .idle
    
    private var recorder: ScreenRecorder?
    private var regionSelector: SafeRegionSelectorWindow?
    private var selectedRegion: CGRect?
    
    func startRegionSelection() {
        guard state == .idle else { return }
        
        state = .selectingRegion
        regionSelector = SafeRegionSelectorWindow { [unowned self] region in
            print("📹 RecordingService received region callback: \(region?.debugDescription ?? "nil")")
            DispatchQueue.main.async {
                self.didSelectRegion(region)
            }
        }
        regionSelector?.orderFrontRegardless()
        print("📹 Region selector window created and shown")
    }
    
    private func didSelectRegion(_ region: CGRect?) {
        print("📹 didSelectRegion called with: \(region?.debugDescription ?? "nil")")
        
        print("📹 Skipping region selector cleanup to avoid crash...")
        // Don't clear the reference - let it clean itself up naturally
        // regionSelector = nil  // COMMENTED OUT TO AVOID CRASH
        
        guard let region = region, region.width > 10, region.height > 10 else {
            print("📹 Invalid region, returning to idle")
            state = .idle
            return
        }
        
        print("📹 Region is valid, storing and starting recording...")
        selectedRegion = region
        print("📹 About to call startRecording...")
        startRecording(region: region)
        print("📹 startRecording call completed")
    }
    
    func startRecording(region: CGRect) {
        guard state == .idle || state == .selectingRegion else { return }
        
        print("🎬 Starting recording for region: \(region)")
        
        // Validate region before creating recorder
        guard region.width > 10 && region.height > 10 else {
            print("❌ Invalid region size: \(region)")
            state = .idle
            return
        }
        
        print("📹 Creating ScreenRecorder...")
        recorder = ScreenRecorder(region: region)
        
        print("📹 Starting recording...")
        Task {
            do {
                try await recorder?.startRecording()
                await MainActor.run {
                    state = .recording(startTime: Date())
                    print("✅ Recording started successfully")
                }
            } catch {
                print("❌ Failed to start recording: \(error)")
                await MainActor.run {
                    state = .idle
                    recorder = nil
                }
            }
        }
    }
    
    func stopRecording() {
        guard case .recording = state else { return }
        
        Task {
            do {
                let url = try await recorder?.stopRecording()
                await MainActor.run {
                    state = .idle
                    recorder = nil
                    if let url = url {
                        showRecordingComplete(url: url)
                    }
                }
            } catch {
                print("❌ Failed to stop recording: \(error)")
                await MainActor.run {
                    state = .idle
                    recorder = nil
                }
            }
        }
    }
    
    private func showRecordingComplete(url: URL) {
        let alert = NSAlert()
        alert.messageText = "Recording Saved"
        alert.informativeText = "Your recording has been saved to:\n\(url.path)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open in Finder")
        alert.addButton(withTitle: "OK")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
        }
    }
}

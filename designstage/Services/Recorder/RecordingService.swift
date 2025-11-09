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
    private var regionSelector: RegionSelectorWindow?
    private var selectedRegion: CGRect?
    
    func startRegionSelection() {
        guard state == .idle else { return }
        
        state = .selectingRegion
        regionSelector = RegionSelectorWindow { [weak self] region in
            self?.didSelectRegion(region)
        }
        regionSelector?.orderFrontRegardless()
    }
    
    private func didSelectRegion(_ region: CGRect?) {
        regionSelector?.close()
        regionSelector = nil
        
        guard let region = region, region.width > 10, region.height > 10 else {
            state = .idle
            return
        }
        
        selectedRegion = region
        startRecording(region: region)
    }
    
    private func startRecording(region: CGRect) {
        recorder = ScreenRecorder(region: region)
        
        Task {
            do {
                try await recorder?.startRecording()
                state = .recording(startTime: Date())
                
                // Auto-stop after 2 minutes
                Task {
                    try? await Task.sleep(nanoseconds: 120_000_000_000)
                    if case .recording = state {
                        stopRecording()
                    }
                }
            } catch {
                print("Failed to start recording: \(error)")
                state = .idle
            }
        }
    }
    
    func stopRecording() {
        guard case .recording = state else { return }
        
        Task {
            do {
                let url = try await recorder?.stopRecording()
                state = .idle
                
                if let url = url {
                    showRecordingComplete(url: url)
                }
            } catch {
                print("Failed to stop recording: \(error)")
                state = .idle
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


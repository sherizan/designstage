//
//  ScreenRecorder.swift
//  Design Stage
//
//  Simple screen recording using ScreenCaptureKit and AVFoundation.
//

import Foundation
import AVFoundation
import ScreenCaptureKit
import CoreGraphics

@available(macOS 12.3, *)
class ScreenRecorder: NSObject, SCStreamOutput {
    private let region: CGRect
    private let outputURL: URL
    private var isRecording = false
    
    // ScreenCaptureKit components - following Apple's pattern
    private var stream: SCStream?
    private var videoWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private let videoQueue = DispatchQueue(label: "VideoQueue", qos: .userInitiated)
    private var sessionStarted = false
    private var frameCount = 0
    
    init(region: CGRect) {
        self.region = region
        
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let filename = "DesignStage-\(dateFormatter.string(from: Date())).mov"
        self.outputURL = desktopPath.appendingPathComponent(filename)
        
        super.init()
        print("📹 ScreenRecorder initialized. Will save to: \(outputURL.path)")
    }
    
    func startRecording() async throws {
        print("📹 Starting recording for region: \(region)")
        
        guard region.width > 0 && region.height > 0 else {
            throw RecordingError.invalidRegion
        }
        
        // Step 1: Get available content (displays) - use main display
        let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        // Find the main display (where the app is running)
        guard let mainScreen = NSScreen.main,
              let display = availableContent.displays.first(where: { $0.displayID == mainScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID }) ?? availableContent.displays.first else {
            throw RecordingError.noDisplayFound
        }
        
        print("📹 Using display: \(display.width)x\(display.height) (ID: \(display.displayID))")
        
        // Step 2: Create content filter - following Apple's pattern
        let filter = SCContentFilter(display: display, excludingWindows: [])
        
        // Step 3: Configure stream - use selected region size
        let streamConfig = SCStreamConfiguration()
        streamConfig.width = Int(region.width)
        streamConfig.height = Int(region.height)
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 15) // 15 fps - easier on the system
        streamConfig.queueDepth = 5
        streamConfig.showsCursor = true
        streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
        
        // Set the source rect to crop to the selected region
        streamConfig.sourceRect = region
        
        print("📹 Stream configured for region: \(region)")
        
        // Step 4: Setup video writer
        try await setupVideoWriter()
        
        // Step 5: Create and start stream - following Apple's pattern
        stream = SCStream(filter: filter, configuration: streamConfig, delegate: nil)
        try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: videoQueue)
        
        isRecording = true
        try await stream?.startCapture()
        
        print("✅ Recording started successfully")
    }
    
    func stopRecording() async throws -> URL {
        print("📹 Stopping recording...")
        
        guard isRecording else {
            throw RecordingError.recordingFailed
        }
        
        isRecording = false
        
        // Stop the stream
        try await stream?.stopCapture()
        
        // Finish writing video
        videoInput?.markAsFinished()
        await videoWriter?.finishWriting()
        
        // Cleanup
        stream = nil
        videoWriter = nil
        videoInput = nil
        pixelBufferAdaptor = nil
        sessionStarted = false
        
        print("📹 Total frames captured: \(frameCount)")
        frameCount = 0
        
        print("✅ Video saved successfully to: \(outputURL.path)")
        return outputURL
    }
    
    // MARK: - Private Methods
    
    private func setupVideoWriter() async throws {
        // Create video writer - try MOV format for better compatibility
        videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        
        // Get the actual display dimensions that we'll be capturing - use main display
        let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        // Find the main display (where the app is running)
        guard let mainScreen = NSScreen.main,
              let display = availableContent.displays.first(where: { $0.displayID == mainScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID }) ?? availableContent.displays.first else {
            throw RecordingError.noDisplayFound
        }
        
        // Use the selected region dimensions for the video output
        let width = Int(region.width)
        let height = Int(region.height)
        
        // Very basic video settings - minimal compression
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        // Create video input
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true
        
        // Create pixel buffer adaptor for direct pixel buffer handling
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput!,
            sourcePixelBufferAttributes: pixelBufferAttributes
        )
        
        guard let videoInput = videoInput,
              let videoWriter = videoWriter,
              videoWriter.canAdd(videoInput) else {
            throw RecordingError.recordingFailed
        }
        
        videoWriter.add(videoInput)
        
        // Start writing session
        guard videoWriter.startWriting() else {
            throw RecordingError.recordingFailed
        }
        
        print("📹 Video writer setup completed - \(width)x\(height)")
    }
    
    // MARK: - SCStreamOutput Delegate
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        // Return early if the sample buffer is invalid - following Apple's pattern
        guard sampleBuffer.isValid else { return }
        
        switch outputType {
        case .screen:
            // Process video frame
            guard isRecording,
                  let videoWriter = videoWriter,
                  let videoInput = videoInput else { return }
            
            // Check writer status first
            guard videoWriter.status == .writing else {
                if frameCount % 30 == 0 { // Don't spam logs
                    print("❌ Writer not in writing state: \(videoWriter.status.rawValue)")
                }
                return
            }
            
            // Check if input is ready (with small delay if not)
            guard videoInput.isReadyForMoreMediaData else {
                // Small delay to prevent overwhelming the writer
                usleep(1000) // 1ms delay
                return
            }
            
            // Debug the first frame to see what we're getting
            if frameCount == 0 {
                if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    let width = CVPixelBufferGetWidth(pixelBuffer)
                    let height = CVPixelBufferGetHeight(pixelBuffer)
                    let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
                    print("📹 First frame format: \(width)x\(height), format: \(format)")
                }
            }
            
            // Start session with first frame timing
            if !sessionStarted {
                let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                videoWriter.startSession(atSourceTime: presentationTime)
                sessionStarted = true
                print("📹 Session started with first frame at time: \(presentationTime)")
            }
            
            // Extract pixel buffer and append using adaptor
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                  let adaptor = pixelBufferAdaptor else {
                return
            }
            
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let success = adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            frameCount += 1
            
            if frameCount == 1 || frameCount % 15 == 0 { // Log first frame and every second at 15fps
                print("📹 Frames written: \(frameCount), append success: \(success)")
                if !success {
                    print("❌ Writer status: \(videoWriter.status.rawValue), error: \(videoWriter.error?.localizedDescription ?? "none")")
                }
            }
            
        case .audio:
            // Audio not implemented yet
            break
        case .microphone:
            // Microphone not implemented yet
            break
        @unknown default:
            break
        }
    }
}

enum RecordingError: Error {
    case noDisplayFound
    case recordingFailed
    case invalidRegion
}

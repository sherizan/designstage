//
//  ScreenRecorder.swift
//  Design Stage
//
//  Handles screen recording using ScreenCaptureKit and AVFoundation.
//

import Foundation
import AVFoundation
import ScreenCaptureKit
import CoreGraphics

@available(macOS 12.3, *)
class ScreenRecorder {
    private let region: CGRect
    private var stream: SCStream?
    private var videoWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var startTime: CMTime?
    private let outputURL: URL
    
    init(region: CGRect) {
        self.region = region
        
        // Generate output file URL
        let documentsPath = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let filename = "DesignStage-\(dateFormatter.string(from: Date())).mov"
        self.outputURL = documentsPath.appendingPathComponent(filename)
    }
    
    func startRecording() async throws {
        // Get shareable content
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        guard let display = content.displays.first else {
            throw RecordingError.noDisplayFound
        }
        
        // Configure stream
        let config = SCStreamConfiguration()
        config.width = Int(region.width * 2) // Retina scaling
        config.height = Int(region.height * 2)
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.sourceRect = region
        config.showsCursor = true
        
        // Create content filter for the display
        let filter = SCContentFilter(display: display, excludingWindows: [])
        
        // Create stream
        stream = SCStream(filter: filter, configuration: config, delegate: nil)
        
        // Set up video writer
        try setupVideoWriter()
        
        guard let stream = stream else {
            throw RecordingError.recordingFailed
        }
        
        // Start capturing
        try await stream.startCapture()
    }
    
    func stopRecording() async throws -> URL {
        if let stream = stream {
            try await stream.stopCapture()
        }
        stream = nil
        
        // Finalize video
        videoInput?.markAsFinished()
        await videoWriter?.finishWriting()
        
        return outputURL
    }
    
    private func setupVideoWriter() throws {
        videoWriter = try AVAssetWriter(url: outputURL, fileType: .mov)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(region.width * 2),
            AVVideoHeightKey: Int(region.height * 2),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true
        
        if let input = videoInput, videoWriter?.canAdd(input) == true {
            videoWriter?.add(input)
        }
        
        videoWriter?.startWriting()
        videoWriter?.startSession(atSourceTime: .zero)
    }
}

enum RecordingError: Error {
    case noDisplayFound
    case recordingFailed
}


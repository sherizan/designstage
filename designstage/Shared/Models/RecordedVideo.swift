//
//  RecordedVideo.swift
//  Design Stage
//
//  Model for recorded video metadata.
//

import Foundation
import AppKit

struct RecordedVideo: Identifiable, Codable {
    let id: UUID
    let url: URL
    let thumbnailPath: String?
    let duration: TimeInterval
    let dimensions: CGSize
    let createdAt: Date
    
    init(id: UUID = UUID(), url: URL, thumbnailPath: String? = nil, duration: TimeInterval, dimensions: CGSize, createdAt: Date = Date()) {
        self.id = id
        self.url = url
        self.thumbnailPath = thumbnailPath
        self.duration = duration
        self.dimensions = dimensions
        self.createdAt = createdAt
    }
    
    var displayDimensions: String {
        return "\(Int(dimensions.width)) × \(Int(dimensions.height))"
    }
    
    var displayDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


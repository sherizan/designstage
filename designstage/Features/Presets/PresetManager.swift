//
//  PresetManager.swift
//  Design Stage
//
//  Manages device frame presets and background options.
//

import Foundation
import CoreGraphics
import AppKit

struct DevicePreset {
    let name: String
    let size: CGSize
    let scaleFactor: CGFloat
    
    static let iPhone15Pro = DevicePreset(
        name: "iPhone 15 Pro",
        size: CGSize(width: 1179, height: 2556),
        scaleFactor: 3.0
    )
    
    static let iPadPro11 = DevicePreset(
        name: "iPad Pro 11\"",
        size: CGSize(width: 1668, height: 2388),
        scaleFactor: 2.0
    )
    
    static let preset1080p = DevicePreset(
        name: "1080p",
        size: CGSize(width: 1920, height: 1080),
        scaleFactor: 1.0
    )
    
    static let preset1440p = DevicePreset(
        name: "1440p",
        size: CGSize(width: 2560, height: 1440),
        scaleFactor: 1.0
    )
    
    static let preset4K = DevicePreset(
        name: "4K",
        size: CGSize(width: 3840, height: 2160),
        scaleFactor: 1.0
    )
    
    static let allPresets: [DevicePreset] = [
        .iPhone15Pro,
        .iPadPro11,
        .preset1080p,
        .preset1440p,
        .preset4K
    ]
}

enum BackgroundStyle {
    case solidColor(NSColor)
    case image(URL)
    case liveBlur
}

@MainActor
class PresetManager: ObservableObject {
    @Published var activeFrames: [FrameWindow] = []
    
    func openFrame(preset: DevicePreset, background: BackgroundStyle = .solidColor(NSColor.white)) {
        let frame = FrameWindow(preset: preset, background: background)
        frame.makeKeyAndOrderFront(nil)
        activeFrames.append(frame)
    }
    
    func closeAllFrames() {
        for frame in activeFrames {
            frame.close()
        }
        activeFrames.removeAll()
    }
}


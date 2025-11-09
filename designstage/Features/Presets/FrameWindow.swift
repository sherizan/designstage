//
//  FrameWindow.swift
//  Design Stage
//
//  Floating window displaying device frame presets.
//

import Cocoa
import SwiftUI

class FrameWindow: NSWindow {
    private let preset: DevicePreset
    private let backgroundStyle: BackgroundStyle
    
    init(preset: DevicePreset, background: BackgroundStyle) {
        self.preset = preset
        self.backgroundStyle = background
        
        // Calculate display size (scale down for screen)
        let displayScale: CGFloat = 0.4
        let displaySize = CGSize(
            width: preset.size.width * displayScale / preset.scaleFactor,
            height: preset.size.height * displayScale / preset.scaleFactor
        )
        
        // Center on main screen
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let origin = CGPoint(
            x: screenFrame.midX - displaySize.width / 2,
            y: screenFrame.midY - displaySize.height / 2
        )
        
        let rect = CGRect(origin: origin, size: displaySize)
        
        super.init(
            contentRect: rect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = preset.name
        self.isMovableByWindowBackground = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Set up content
        setupContentView()
    }
    
    private func setupContentView() {
        let hostingView = NSHostingView(rootView: FrameContentView(
            preset: preset,
            backgroundStyle: backgroundStyle
        ))
        
        self.contentView = hostingView
    }
}

struct FrameContentView: View {
    let preset: DevicePreset
    let backgroundStyle: BackgroundStyle
    
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Info overlay
            VStack {
                Spacer()
                HStack {
                    Text(preset.name)
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(preset.size.width)) × \(Int(preset.size.height))")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(Color.black.opacity(0.6))
            }
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch backgroundStyle {
        case .solidColor(let nsColor):
            Color(nsColor: nsColor)
        case .image(let url):
            if let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray
            }
        case .liveBlur:
            // Visual effect view for blur
            VisualEffectView()
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

extension Color {
    init(nsColor: NSColor) {
        self.init(
            red: Double(nsColor.redComponent),
            green: Double(nsColor.greenComponent),
            blue: Double(nsColor.blueComponent),
            opacity: Double(nsColor.alphaComponent)
        )
    }
}


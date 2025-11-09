# Design Stage

A lightweight macOS menu bar app that lets creators draw, highlight, record, and showcase design or screen content beautifully during meetings, demos, or recordings.

## 🎯 Features

- **✏️ Draw Anywhere**: Freehand drawing overlay across all screens with global hotkey (`⌘⇧D`)
- **🧹 Clear Ink**: Instantly wipe drawings (`⌘⇧C`)
- **🌈 Color Presets**: 5 vibrant colors (Yellow, Red, Blue, Green, White)
- **🔥 Fade Ink**: Strokes auto-fade after configurable durations (Off, 5s, 10s, 20s)
- **🎥 Screen Recorder**: Select region with preset dimensions (1080x1080, 1280x720, 393x852), drag edges to customize, and record to .mov with video gallery (`⌘⇧R`)
- **📱 Device Frames**: Preset floating windows (iPhone 15 Pro, iPad Pro, 1080p, 1440p, 4K)
- **💾 Export Snapshot**: Capture screen with overlays (`⌘⇧S`)

## 🎬 Recording Feature Highlights

The enhanced screen recording feature provides a complete recording workflow:

1. **Interactive Region Selection**: Start with preset dimensions (Square, Landscape, Portrait)
2. **Draggable Edges**: Customize recording area by dragging corners and edges
3. **Live Dimension Display**: See exact pixel dimensions in real-time
4. **Recording Control Bar**: Beautiful UI with record button, preset selector, and dimension display
5. **Video Gallery**: Thumbnail preview of all recordings with duration and quick actions
6. **High-Quality Output**: H.264 MOV files at 2× resolution (Retina) saved to Movies folder

See [RECORDING_GUIDE.md](RECORDING_GUIDE.md) for detailed usage instructions.

## 🏗 Architecture

### Modern SwiftUI + AppKit Hybrid

```
DesignStage/
├── App/                          # Application entry point
│   ├── DesignStageApp.swift     # @main SwiftUI app
│   ├── AppDelegate.swift         # Menu bar coordination & lifecycle
│   └── MenuBar/
│       └── StatusItemController.swift  # Menu bar UI logic
│
├── Features/                     # Feature modules (MVVM pattern)
│   ├── Drawing/
│   │   ├── DrawingViewController.swift  # Stroke input handling
│   │   └── DrawingView.swift           # NSView-based rendering
│   ├── Recording/
│   ├── Presets/
│   │   ├── PresetManager.swift         # Device frame management
│   │   └── FrameWindow.swift           # SwiftUI frame windows
│   └── Export/
│       └── ExportService.swift         # Snapshot export
│
├── Services/                     # Shared business logic
│   ├── OverlayService.swift      # Drawing overlay coordinator
│   ├── OverlayWindow.swift       # Transparent NSPanel
│   ├── FadeEngine.swift          # Actor-based stroke fading
│   ├── HotkeyManager.swift       # Global shortcuts (Carbon API)
│   └── Recorder/
│       ├── EnhancedRecordingService.swift  # Enhanced recording state machine
│       ├── EnhancedRegionSelectorWindow.swift  # Interactive region with draggable edges
│       ├── RecordingControlBar.swift       # Control bar UI with presets
│       ├── VideoThumbnailGallery.swift     # Gallery view for recordings
│       ├── ScreenRecorder.swift         # ScreenCaptureKit integration
│       ├── RecordingService.swift       # Basic recording (legacy)
│       └── RegionSelectorWindow.swift   # Basic region picker (legacy)
│
├── Shared/                       # Utilities & models
│   ├── Models/
│   │   ├── Stroke.swift          # Drawing stroke data
│   │   ├── DrawingColor.swift    # Color presets
│   │   ├── FadeMode.swift        # Fade duration modes
│   │   ├── RecordingPreset.swift # Recording dimension presets
│   │   └── RecordedVideo.swift   # Video metadata model
│   ├── Utilities/
│   │   └── PermissionsManager.swift  # Screen recording permissions
│   └── Extensions/
│
└── Resources/
    ├── Assets.xcassets/
    └── Info.plist
```

## 🛠 Technical Highlights

- **Language**: Swift 5.0
- **Minimum macOS**: 13.0 (Ventura)
- **Frameworks**: 
  - SwiftUI for app lifecycle
  - AppKit for overlay windows & menu bar
  - ScreenCaptureKit for modern recording (macOS 12.3+)
  - AVFoundation for MOV encoding
  - ImageIO for GIF export
  - QuartzCore for rendering & animations

### Key Design Patterns

1. **Overlay Rendering**: Transparent `NSPanel` at `.screenSaver` level with `CVDisplayLink` for 60fps updates
2. **Fade Engine**: Actor-isolated timing engine using `CACurrentMediaTime()` with ease-out quad interpolation
3. **Hotkey Manager**: Carbon API wrapper for global shortcuts (no accessibility permissions needed)
4. **Recording Pipeline**: 
   - ScreenCaptureKit for capture
   - AVAssetWriter for MOV encoding
   - CGImageDestination for GIF encoding (10-15 FPS)
5. **Permissions**: Async permission requests with helpful alerts

### Performance Targets

- **CPU**: < 5% idle
- **Memory**: < 100MB
- **Rendering**: 60fps drawing with smooth fade transitions

## 🚀 Getting Started

### Building

```bash
open designstage.xcodeproj
```

Build and run from Xcode (⌘R)

### Permissions

On first launch, Design Stage will request:
- **Screen Recording**: Required for overlay and recording features

Grant these in **System Preferences > Privacy & Security > Screen Recording**

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧D` | Toggle drawing mode |
| `⌘⇧C` | Clear all drawings |
| `⌘⇧F` | Cycle fade mode |
| `⌘⇧R` | Start/Stop recording |
| `⌘⇧S` | Export snapshot |

## 📦 Distribution

- Entitlements configured for macOS app sandbox (currently disabled for development)
- Hardened runtime enabled
- Ready for notarization

## 🧪 Future Enhancements

- [ ] GIF encoder implementation
- [ ] Custom color picker
- [ ] Pen pressure support (Apple Pencil)
- [ ] Multiple stroke widths
- [ ] Undo/Redo
- [ ] Export formats (SVG, PDF)
- [ ] Background styles for preset frames
- [ ] Touch Bar shortcuts
- [ ] Cloud sync for recordings

## 📄 License

Copyright © 2025. All rights reserved.

